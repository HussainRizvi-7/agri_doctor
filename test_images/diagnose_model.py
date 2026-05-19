"""
Agri-Doctor TFLite Pipeline Diagnostic
=======================================
Runs inference on all test images and compares both normalization strategies.
Requires: pip install tensorflow-cpu Pillow numpy
"""

import sys
sys.stdout.reconfigure(encoding='utf-8')

import numpy as np
from PIL import Image
import os

MODEL_PATH = "../assets/model/model.tflite"
LABELS_PATH = "../assets/model/labels.txt"
IMAGES_DIR = "."

EXPECTED = {
    "pepper-bell-bacteriaspot.jpg":  (18, "pepper bell bacterial spot"),
    "potato-lateblight.jpg":         (21, "potato late blight"),
    "tomato-earlyblight.jpg":        (29, "tomato early blight"),
    "tomato-healthy.jpg":            (37, "tomato healthy"),
    "tomato-leafmold.jpg":           (31, "tomato leaf mold"),
}

# ── Load labels ──────────────────────────────────────────────────────────────
with open(LABELS_PATH, encoding="utf-8") as f:
    labels = [l.strip() for l in f if l.strip()]
print(f"Labels loaded: {len(labels)}")

# ── Load TFLite interpreter ───────────────────────────────────────────────────
interpreter = None
for _loader in [
    lambda: __import__('ai_edge_litert.interpreter', fromlist=['Interpreter']).Interpreter(model_path=MODEL_PATH),
    lambda: __import__('tensorflow', fromlist=['lite']).lite.Interpreter(model_path=MODEL_PATH),
    lambda: __import__('tflite_runtime.interpreter', fromlist=['Interpreter']).Interpreter(model_path=MODEL_PATH),
]:
    try:
        interpreter = _loader()
        break
    except (ImportError, Exception):
        pass
if interpreter is None:
    print("ERROR: Install ai-edge-litert, tensorflow-cpu, or tflite-runtime.")
    sys.exit(1)

interpreter.allocate_tensors()
input_details  = interpreter.get_input_details()
output_details = interpreter.get_output_details()

inp = input_details[0]
out = output_details[0]

INPUT_SHAPE = inp["shape"]          # e.g. [1, 200, 200, 3]
INPUT_DTYPE = inp["dtype"]
H = INPUT_SHAPE[1]
W = INPUT_SHAPE[2]

print(f"\n{'='*60}")
print(f"MODEL INTROSPECTION")
print(f"{'='*60}")
print(f"Input  tensor:  shape={INPUT_SHAPE}, dtype={INPUT_DTYPE.__name__}")
print(f"Output tensor:  shape={out['shape']}, dtype={out['dtype'].__name__}")
print(f"Input quantization: scale={inp.get('quantization', (0,0))[0]}, "
      f"zero_point={inp.get('quantization', (0,0))[1]}")


def run_inference(image_path, norm_mode):
    """norm_mode: '0_1' or 'neg1_1'"""
    img = Image.open(image_path).convert("RGB")
    img = img.resize((W, H), Image.BILINEAR)
    arr = np.array(img, dtype=np.float32)

    if norm_mode == "0_1":
        arr = arr / 255.0
    elif norm_mode == "neg1_1":
        arr = (arr / 127.5) - 1.0
    elif norm_mode == "raw":
        pass  # no normalization

    arr = np.expand_dims(arr, axis=0)  # [1, H, W, 3]
    interpreter.set_tensor(inp["index"], arr)
    interpreter.invoke()
    probs = interpreter.get_tensor(out["index"])[0]  # [39]
    return probs


def top_k(probs, k=3):
    indices = np.argsort(probs)[::-1][:k]
    return [(i, float(probs[i]), labels[i]) for i in indices]


print(f"\n{'='*60}")
print(f"INFERENCE RESULTS")
print(f"{'='*60}")

for norm_name, norm_mode in [("Norm [0,1]  (÷255)", "0_1"),
                              ("Norm [-1,1] (MobileNet)", "neg1_1"),
                              ("No norm     (raw uint8)", "raw")]:
    print(f"\n--- Normalization: {norm_name} ---")
    correct = 0
    for fname, (exp_idx, exp_label) in EXPECTED.items():
        path = os.path.join(IMAGES_DIR, fname)
        if not os.path.exists(path):
            print(f"  MISSING: {fname}")
            continue

        probs = run_inference(path, norm_mode)
        top3  = top_k(probs, 3)

        pred_idx, pred_conf, pred_label = top3[0]
        hit = "OK" if pred_idx == exp_idx else "WRONG"
        if pred_idx == exp_idx:
            correct += 1

        print(f"\n  {fname}")
        print(f"    Expected : [{exp_idx:2d}] {exp_label}")
        print(f"    Predicted: [{pred_idx:2d}] {pred_label}  ({pred_conf*100:.1f}%)  [{hit}]")
        print(f"    Top-3:")
        for rank, (idx, conf, lbl) in enumerate(top3, 1):
            marker = "<-- EXPECTED" if idx == exp_idx else ""
            print(f"      #{rank}  [{idx:2d}] {lbl:<50s} {conf*100:5.1f}%  {marker}")

    print(f"\n  Accuracy: {correct}/{len(EXPECTED)}  ({correct/len(EXPECTED)*100:.0f}%)")

print(f"\n{'='*60}")
print("DIAGNOSIS COMPLETE")
print(f"{'='*60}")
