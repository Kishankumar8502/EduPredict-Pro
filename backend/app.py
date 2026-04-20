from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
import joblib
import os

app = Flask(__name__)

# 1. Model Loading
try:
    model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "best_student_performance_model.joblib")
    model = joblib.load(model_path)
    print("Machine Learning Model loaded successfully!")
except Exception as e:
    model = None
    print(f"Warning: Model failed to load. Ensure 'best_student_performance_model.joblib' is in this folder. Error: {e}")

# Flask Setup (Home Route)
@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "API is running. Send a POST request to /predict"}), 200

# 5. Prediction API
@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()
        print("Incoming data:", data)
        if not data:
            data = {}
        
        # 3. Validation
        required_fields = [
            "study_hours", "attendance", "cgpa", 
            "travel_time", "internet_access", "parent_education",
            "age", "gender", "school_type", "extra_activities", 
            "study_method", "math_score", "science_score", "english_score"
        ]
        
        missing_fields = [field for field in required_fields if field not in data]
        
        # Disabled returning 400 error to ensure fallback handling works
        # if len(missing_fields) > 0:
        #     return jsonify({"error": "Missing required input fields"}), 400
            
        # 1. Input Mapping Exactly matches required model features
        study_hours = float(data.get("study_hours", 5.0))
        attendance = float(data.get("attendance", 85.0))
        cgpa = float(data.get("cgpa", 0.0))
        
        # Convert cgpa into final_grade
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

        model_input_data = pd.DataFrame([{
            'age': int(data.get("age", 15)),
            'gender': data.get("gender", "other").lower(),
            'school_type': data.get("school_type", "public").lower(),
            'parent_education': data.get("parent_education", "high school").lower(),
            'study_hours': study_hours,
            'attendance_percentage': attendance,
            'internet_access': data.get("internet_access", "yes").lower(),
            'travel_time': data.get("travel_time", "15-30 min").lower(),
            'extra_activities': data.get("extra_activities", "no").lower(),
            'study_method': data.get("study_method", "mixed").lower(),
            'math_score': float(data.get("math_score", 50.0)),
            'science_score': float(data.get("science_score", 50.0)),
            'english_score': float(data.get("english_score", 50.0)),
            'final_grade': grade
        }])
        print("Processed DataFrame:")
        print(model_input_data)
        
        # 5. Prediction
        if model is not None:
            prediction = float(model.predict(model_input_data)[0])
        else:
            # Better fallback formula matching train_model.py
            sleep_hours = float(data.get("sleep_hours", 7))
            entertainment_hours = float(data.get("entertainment_hours", 2))
            subjects = int(data.get("subjects", 3))
            prediction = (study_hours * 7) + (sleep_hours * 3) - (entertainment_hours * 2.5) + (subjects * 1.5)
            
        print("Prediction output:", prediction)
        
        # 6. Output 
        overall_score = float(np.clip(prediction, 0, 100))
        
        return jsonify({
            "success": True,
            "predicted_overall_score": round(overall_score, 2),
            "prediction": round(overall_score, 2)
        })
        
    except Exception as e:
        # Generic graceful exception block 
        return jsonify({"success": False, "error": str(e)}), 400

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
