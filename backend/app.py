from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
import joblib

app = Flask(__name__)

import os
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
    if model is None:
        return jsonify({"error": "Model not found on the server."}), 500
        
    try:
        data = request.get_json()
        
        # 3. Validation
        # The list of exact features expected based on our training DataFrame
        # Notice we don't strictly require "sleep_hours" in validation because our CSV dataset didn't use it,
        # but we allow it as a passable valid property.
        required_fields = [
            "study_hours", "attendance", "cgpa", 
            "travel_time", "internet_access", "parent_education",
            "age", "gender", "school_type", "extra_activities", 
            "study_method", "math_score", "science_score", "english_score"
        ]
        
        # Safely enforce that NO fields are missing. Do NOT explicitly pull defaults anymore!
        missing_fields = [field for field in required_fields if field not in data]
        
        if len(missing_fields) > 0:
            # Explicitly return 400 Error requirement
            return jsonify({"error": "Missing required input fields"}), 400
            
        # 1. Input Handling
        # We explicitly extract exactly what was sent mathematically
        study_hours = float(data["study_hours"])
        attendance  = float(data["attendance"])
        cgpa        = float(data["cgpa"])
        
        travel_time = data["travel_time"]
        internet_access = data["internet_access"]
        parent_education = data["parent_education"]
        
        # New Strict Features
        age = int(data["age"])
        gender = data["gender"]
        school_type = data["school_type"]
        extra_activities = data["extra_activities"]
        study_method = data["study_method"]
        math_score = float(data["math_score"])
        science_score = float(data["science_score"])
        english_score = float(data["english_score"])

        # 4. Processing
        # Map CGPA (1.0 to 10.0) into grade categories (internally mapped to 0-5)
        # 5 -> A, 4 -> B, 3 -> C, 2 -> D, 1 -> E, 0 -> F (Same logic as before!)
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
        # Convert input JSON into pandas DataFrame mapping directly to our pipeline's precise specification headers
        input_data = pd.DataFrame([{
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
        
        # 5. Prediction
        # Pass complete input data to model.predict()
        prediction = model.predict(input_data)[0]
        
        # 6. Output 
        # Return predicted overall_score (Ensure output is realistic between 0 and 100 limit)
        overall_score = float(np.clip(prediction, 0, 100))
        
        return jsonify({
            "success": True,
            "predicted_overall_score": round(overall_score, 2)
        })
        
    except Exception as e:
        # Generic graceful exception block 
        return jsonify({"success": False, "error": str(e)}), 400

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
