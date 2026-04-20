import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import r2_score, mean_squared_error
import joblib

def build_student_performance_model():
    print("1. Loading dataset...")
    # Read dataset from the same folder
    try:
        import os
        csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Student_Performance.csv")
        df = pd.read_csv(csv_path)
        print(f"Dataset successfully loaded! Dimensions: {df.shape}")
    except FileNotFoundError:
        print("Error: 'Student_Performance.csv' not found in the current directory.")
        return
        
    # 2. Problem Definition:
    # Target: overall_score
    # Features: All remaining columns (student_id should be dropped as it's not predictive)
    if "student_id" in df.columns:
        df = df.drop(columns=["student_id"])

    # 3. Data Preprocessing:
    # Handle missing values by dropping them (or you could fill them)
    df = df.dropna()

    # Leave final_grade as string to be processed categorically by the pipeline
    if 'final_grade' in df.columns:
        df['final_grade'] = df['final_grade'].str.lower()
        df = df.dropna(subset=['final_grade'])

    # Separate features (X) and target (y)
    X = df.drop(columns=["overall_score"])
    y = df["overall_score"]

    # Identify numerical and categorical columns
    categorical_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
    numerical_cols = X.select_dtypes(include=['int64', 'float64']).columns.tolist()

    print(f"Categorical features: {categorical_cols}")
    print(f"Numerical features: {numerical_cols}")

    # Build Preprocessing Pipeline
    # OneHotEncoding for Categorical Data; Pass-through for Numerical Data
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', 'passthrough', numerical_cols),
            ('cat', OneHotEncoder(handle_unknown='ignore', drop='first'), categorical_cols)
        ]
    )

    # 4. Model Building & 5. Training
    # Split data (80% train, 20% test)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    print(f"\nData Split Complete -> Training set: {X_train.shape[0]}, Test set: {X_test.shape[0]}")

    # Create model pipelines
    lr_model = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('model', LinearRegression())
    ])

    dt_model = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('model', DecisionTreeRegressor(max_depth=10, random_state=42))
    ])

    print("Training Linear Regression...")
    lr_model.fit(X_train, y_train)

    print("Training Decision Tree Regressor...")
    dt_model.fit(X_train, y_train)

    # 6. Evaluation
    lr_preds = lr_model.predict(X_test)
    dt_preds = dt_model.predict(X_test)

    # 7. Output Handling - Ensure realistic predictions (between 0 and 100)
    lr_preds = np.clip(lr_preds, 0, 100)
    dt_preds = np.clip(dt_preds, 0, 100)

    # Calculate R2 Scores
    lr_r2 = r2_score(y_test, lr_preds)
    dt_r2 = r2_score(y_test, dt_preds)
    
    # Calculate RMSE
    lr_rmse = np.sqrt(mean_squared_error(y_test, lr_preds))
    dt_rmse = np.sqrt(mean_squared_error(y_test, dt_preds))

    print("\n--- Evaluation Results ---")
    print(f"Linear Regression R² Score: {lr_r2:.4f} | RMSE: {lr_rmse:.4f}")
    print(f"Decision Tree R² Score: {dt_r2:.4f} | RMSE: {dt_rmse:.4f}")

    # Show a few predictions vs actual
    print("\nSample Predictions (Linear Reg vs Actual):")
    sample_outputs = pd.DataFrame({
        'Actual Score': y_test.values[:5],
        'LR Predicted': lr_preds[:5].round(2),
        'DT Predicted': dt_preds[:5].round(2)
    })
    print(sample_outputs.to_string(index=False))

    # 8. Model Saving
    # Choose best model based on R2 Score
    if lr_r2 > dt_r2:
        best_model = lr_model
        best_model_name = "Linear Regression"
    else:
        best_model = dt_model
        best_model_name = "Decision Tree Regressor"

    print(f"\nBest Model identified: {best_model_name}")
    
    # Save using joblib
    import os
    model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "best_student_performance_model.joblib")
    joblib.dump(best_model, model_path)
    print("Model saved to 'best_student_performance_model.joblib'")
    print("You can easily load this model in your Flask app using: joblib.load('best_student_performance_model.joblib')")

if __name__ == "__main__":
    build_student_performance_model()
