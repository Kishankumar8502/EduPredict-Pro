import streamlit as st
import pandas as pd
import numpy as np
import joblib
import os

# 7. Extra UI Improvements: Title & Clean Interface
st.set_page_config(page_title="Student Performance Predictor", page_icon="🎓", layout="centered")

st.title("🎓 Student Performance Predictor")
st.markdown("Enter student habits (average study, sleep, etc.) below and instantly get a predicted performance score along with feedback based on our Machine Learning model.")

# 1. Model Loading
@st.cache_resource
def load_trained_model():
    model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "best_student_performance_model.joblib")
    if os.path.exists(model_path):
        return joblib.load(model_path)
    else:
        st.error(f"⚠️ Model file '{model_path}' not found! Please ensure it's in the same folder.")
        return None

model = load_trained_model()

# 2. UI Design
st.header("1. Habits & Time Management")
col1, col2 = st.columns(2)

with col1:
    # Slider: 0 - 24
    study_hours = st.slider("Average Study Hours per Day", min_value=0.0, max_value=24.0, value=5.0, step=0.5)

with col2:
    # Logic: Make sure adding both should not exceed 24 hrs
    max_sleep = 24.0 - study_hours
    # Safety fallback in case max_sleep goes below min bounds
    if max_sleep < 0: max_sleep = 0.0 
    
    sleep_hours = st.slider(
        "Average Sleep Hours per Day", 
        min_value=0.0, 
        max_value=float(max_sleep), 
        value=min(8.0, max_sleep), 
        step=0.5,
        help="Study + Sleep cannot exceed 24 hours."
    )

st.header("2. Academic Details")
col3, col4 = st.columns(2)

with col3:
    attendance_percentage = st.slider("Attendance Percentage (%)", min_value=0.0, max_value=100.0, value=85.0, step=1.0)
    final_grade = st.selectbox("Final Grade", options=['A', 'B', 'C', 'D', 'E', 'F'])

with col4:
    age = st.slider("Age", min_value=10, max_value=30, value=16)
    school_type = st.selectbox("School Type", options=["public", "private"])

st.header("3. Core Subject Scores")
s_col1, s_col2, s_col3 = st.columns(3)
with s_col1:
    math_score = st.slider("Math", min_value=0.0, max_value=100.0, value=75.0, step=1.0)
with s_col2:
    science_score = st.slider("Science", min_value=0.0, max_value=100.0, value=75.0, step=1.0)
with s_col3:
    english_score = st.slider("English", min_value=0.0, max_value=100.0, value=75.0, step=1.0)

st.header("4. Demographics & Study Strategy")
o_col1, o_col2 = st.columns(2)

with o_col1:
    gender = st.selectbox("Gender", options=["male", "female", "other"])
    parent_education = st.selectbox("Parent Education", options=["no formal", "high school", "diploma", "graduate", "post graduate", "phd"])
    internet_access = st.selectbox("Internet Access", options=["yes", "no"])

with o_col2:
    travel_time = st.selectbox("Travel Time", options=["<15 min", "15-30 min", "30-60 min", ">60 min"])
    extra_activities = st.selectbox("Extracuriculars", options=["yes", "no"])
    study_method = st.selectbox("Study Method", options=["notes", "textbook", "online videos", "group study", "coaching", "mixed"])

# 4. Prediction
st.markdown("---")
if st.button("Predict Performance", type="primary", use_container_width=True):
    if model is not None:
        
        # 3. Input Handling
        # Convert grade input (A-F) into lower-case logic that matched our mapping earlier in ml_pipeline.py
        grade_mapping = {'a': 5, 'b': 4, 'c': 3, 'd': 2, 'e': 1, 'f': 0}
        numeric_grade = grade_mapping[final_grade.lower()]

        # Note: 'sleep_hours' was requested on the UI so it's included,
        # but our training dataset "Student_Performance.csv" didn't have a 'sleep_hours' column.
        # We only pass features that the pipeline specifically saw during train.
        input_data = pd.DataFrame([{
            'age': age,
            'gender': gender,
            'school_type': school_type,
            'parent_education': parent_education,
            'study_hours': study_hours,
            'attendance_percentage': attendance_percentage,
            'internet_access': internet_access,
            'travel_time': travel_time,
            'extra_activities': extra_activities,
            'study_method': study_method,
            'math_score': math_score,
            'science_score': science_score,
            'english_score': english_score,
            'final_grade': numeric_grade
        }])

        try:
            # Predict
            pred = model.predict(input_data)[0]
            
            # Ensure output is realistic (between 0-100)
            pred_score = np.clip(pred, 0, 100)
            pred_score_rounded = round(pred_score, 1)
            
            # 5. Output Results Display
            st.subheader("Results")
            st.metric("Predicted Overall Score", f"{pred_score_rounded} / 100")
            
            # 6. Performance Message
            if pred_score_rounded > 75:
                st.success("Good Performance 🎯")
            elif 50 <= pred_score_rounded <= 75:
                st.warning("Average Performance 👍")
            elif pred_score_rounded < 50:
                st.error("Needs Improvement ⚠️")
                
        except Exception as e:
            st.error(f"Something went wrong processing your prediction: {e}")
