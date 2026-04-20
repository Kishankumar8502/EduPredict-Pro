from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
import joblib
import os

app = Flask(__name__)

# ✅ MODEL LOADING (FIXED + DEBUG)
model = None
model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "best_model.joblib")

print("🔍 Trying to load model from:", model_path)

try:
    if os.path.exists(model_path):
        model = joblib.load(model_path)
        print("✅ Model loaded successfully!")
        print("📦 Model type:", type(model))
    else:
        print("❌ Model not found at path:", model_path)
except Exception as e:
    print("❌ Model loading failed:", e)
    model = None

# HOME ROUTE
@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "API is running. Send POST to /predict"}), 200

# ✅ PREDICTION ROUTE (FIXED)
@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()
        print("📥 Incoming:", data)

        if not data:
            return jsonify({"success": False, "error": "No input data"}), 400

        # CRITICAL FIX: Fail early if no model loaded
        if model is None:
            return jsonify({
                "success": False,
                "error": "Model not loaded properly"
            }), 500

        # ✅ CGPA → GRADE
        cgpa = float(data.get("cgpa", 0))

        if cgpa >= 9:
            grade = 'a'
        elif cgpa >= 8:
            grade = 'b'
        elif cgpa >= 7:
            grade = 'c'
        elif cgpa >= 6:
            grade = 'd'
        elif cgpa >= 5:
            grade = 'e'
        else:
            grade = 'f'

        # ✅ DATAFRAME (STRICT MATCH WITH DATASET)
        df = pd.DataFrame([{
            'age': int(data.get("age", 15)),
            'gender': str(data.get("gender", "other")).lower(),
            'school_type': str(data.get("school_type", "public")).lower(),
            'parent_education': str(data.get("parent_education", "high school")).lower(),
            'study_hours': float(data.get("study_hours", 5)),
            'attendance_percentage': float(data.get("attendance", 85)),
            'internet_access': str(data.get("internet_access", "yes")).lower(),
            'travel_time': str(data.get("travel_time", "15-30 min")).lower(),
            'extra_activities': str(data.get("extra_activities", "no")).lower(),
            'study_method': str(data.get("study_method", "mixed")).lower(),
            'math_score': float(data.get("math_score", 50)),
            'science_score': float(data.get("science_score", 50)),
            'english_score': float(data.get("english_score", 50)),
            'final_grade': grade
        }])

        print("📊 Processed DF:")
        print(df)

        # ✅ PREDICTION SAFE CALL
        prediction = model.predict(df)

        # ⚠️ HANDLE PIPELINE RETURN
        if isinstance(prediction, (list, np.ndarray)):
            prediction = float(prediction[0])
        else:
            prediction = float(prediction)

        print("🎯 Raw Prediction:", prediction)

        score = float(np.clip(prediction, 0, 100))

        # ✅ LEVEL LOGIC
        if score >= 85:
            level = "Excellent"
        elif score >= 70:
            level = "Good"
        elif score >= 50:
            level = "Average"
        else:
            level = "Needs Improvement"

        improvement = f"+{round(100 - score, 2)} marks possible"

        return jsonify({
            "success": True,
            "prediction": round(score, 2),
            "predicted_overall_score": round(score, 2),
            "level": level,
            "improvement": improvement
        })

    except Exception as e:
        print("❌ ERROR:", e)
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)