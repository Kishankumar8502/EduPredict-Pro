import pandas as pd
import numpy as np
import os
import joblib
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.linear_model import LinearRegression

def build_student_performance_model():
    print("1. Loading dataset...")
    csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Student_Performance.csv")
    
    try:
        df = pd.read_csv(csv_path)
        print(f"Dataset successfully loaded! Dimensions: {df.shape}")
    except FileNotFoundError:
        print("❌ Error: 'Student_Performance.csv' not found.")
        return
        
    # 2. Problem Definition:
    if "student_id" in df.columns:
        df = df.drop(columns=["student_id"])

    # 3. Data Preprocessing:
    df = df.dropna()

    if 'final_grade' in df.columns:
        df['final_grade'] = df['final_grade'].str.lower()
        df = df.dropna(subset=['final_grade'])

    X = df.drop(columns=["overall_score"])
    y = df["overall_score"]

    categorical_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
    numerical_cols = X.select_dtypes(include=['int64', 'float64']).columns.tolist()

    print(f"Categorical features: {categorical_cols}")
    print(f"Numerical features: {numerical_cols}")

    # Build Preprocessing Pipeline
    # strict classes only - no string values
    num_transformer = StandardScaler()
    cat_transformer = OneHotEncoder(handle_unknown='ignore', drop='first')

    preprocessor = ColumnTransformer(
        transformers=[
            ('num', num_transformer, numerical_cols),
            ('cat', cat_transformer, categorical_cols)
        ]
    )

    # Wrap into master pipeline
    model = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('model', LinearRegression())
    ])

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    print(f"\nTraining set: {X_train.shape[0]}, Test set: {X_test.shape[0]}")

    print("Training Pipeline Full Construction...")
    model.fit(X_train, y_train)

    # Ensure constraints logic
    train_score = model.score(X_train, y_train)
    test_score = model.score(X_test, y_test)

    print("\n--- Evaluation Results ---")
    print(f"Pipeline R² Score: {test_score:.4f} (Train: {train_score:.4f})")

    # Save cleanly as best_model.joblib
    model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "best_model.joblib")
    
    # Prune old dependencies safely
    for old_file in ["best_model.joblib", "best_student_performance_model.joblib", "model.pkl"]:
        p = os.path.join(os.path.dirname(os.path.abspath(__file__)), old_file)
        if os.path.exists(p):
            os.remove(p)
            
    joblib.dump(model, model_path)
    print(f"Pipeline + Model cleanly saved to '{model_path}'")

if __name__ == "__main__":
    build_student_performance_model()
