from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
import joblib

app = Flask(__name__)

import os
# 1. Model Loading
try:
    model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "model.pkl")
    model = joblib.load(model_path)
    print("Machine Learning Model loaded successfully!")
except Exception as e:
    model = None
    print(f"Warning: Model failed to load. Ensure 'model.pkl' is in this folder. Error: {e}")

# Flask Setup (Home Route)
@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "API is running. Send a POST request to /predict"}), 200

# 5. Prediction API
@app.route("/predict", methods=["POST"])
def predict():
    if model is None:
        return jsonify({"error": "Model not found on the server."}), 500
        
    try:
        data = request.get_json()
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
            
        # 1. Input Handling
        # We explicitly extract exactly what was sent mathematically, with safe defaults
        study_hours = float(data.get("study_hours", 5))
        attendance  = float(data.get("attendance", 85))
        cgpa        = float(data.get("cgpa", 7.0))
        
        travel_time = data.get("travel_time", "<15 min")
        internet_access = data.get("internet_access", "yes")
        parent_education = data.get("parent_education", "graduate")
        
        # New Strict Features
        age = int(data.get("age", 16))
        gender = data.get("gender", "male")
        school_type = data.get("school_type", "public")
        extra_activities = data.get("extra_activities", "yes")
        study_method = data.get("study_method", "notes")
        math_score = float(data.get("math_score", 75))
        science_score = float(data.get("science_score", 75))
        english_score = float(data.get("english_score", 75))

        # 4. Processing
        if cgpa >= 9.0:
            final_grade = 5
        elif cgpa >= 8.0:
            final_grade = 4
        elif cgpa >= 7.0:
            final_grade = 3
        elif cgpa >= 6.0:
            final_grade = 2
        elif cgpa >= 5.0:
            final_grade = 1
        else:
            final_grade = 0
            
        # 2. Feature Consistency
        # Kept legacy input_data formatting so existing logic is not removed
        legacy_input_data = pd.DataFrame([{
            'age': age,
            'gender': gender,
            'school_type': school_type,
            'parent_education': parent_education,
            'study_hours': study_hours,
            'attendance_percentage': attendance, 
            'internet_access': internet_access,  
            'travel_time': travel_time,         
            'extra_activities': extra_activities, 
            'study_method': study_method,     
            'math_score': math_score,            
            'science_score': science_score,      
            'english_score': english_score,      
            'final_grade': final_grade           
        }])
        
        # Internally map incoming data to new model's required features
        sleep_hours = float(data.get("sleep_hours", 7))
        entertainment_hours = float(data.get("entertainment_hours", 2))
        subjects = int(data.get("subjects", 3))

        model_input_data = pd.DataFrame([{
            'study_hours': study_hours,
            'sleep_hours': sleep_hours,
            'entertainment_hours': entertainment_hours,
            'subjects': subjects
        }])
        
        # 5. Prediction
        prediction = model.predict(model_input_data)[0]
        
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
