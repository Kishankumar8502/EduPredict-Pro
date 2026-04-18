import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
import pickle

def train_dummy_model():
    print("Generating synthetic data for Student Performance Model...")
    # Features: Study hours, Sleep hours, Entertainment hours, Subjects (encoded as int)
    np.random.seed(42)
    n_samples = 1500
    
    # Generate realistic ranges for students
    study_hours = np.random.uniform(0, 10, n_samples)
    sleep_hours = np.random.uniform(4, 10, n_samples)
    entertainment_hours = np.random.uniform(0, 6, n_samples)
    subjects = np.random.randint(1, 6, n_samples) # E.g., 1 to 5 subjects
    
    # Target: Performance score (0-100)
    # Give positive weights to study and sleep, negative weight to extreme entertainment
    score = (study_hours * 5.5) + (sleep_hours * 4.0) - (entertainment_hours * 2.5) + (subjects * 1.5) + np.random.normal(0, 4, n_samples)
    score = np.clip(score, 0, 100)
    
    # Create DataFrame
    X = pd.DataFrame({
        'study_hours': study_hours,
        'sleep_hours': sleep_hours,
        'entertainment_hours': entertainment_hours,
        'subjects': subjects
    })
    y = score
    
    print("Training RandomForest Regression model...")
    # Train the Machine Learning model
    model = RandomForestRegressor(n_estimators=100, max_depth=10, random_state=42)
    model.fit(X, y)
    
    print("Evaluating model...")
    train_score = model.score(X, y)
    print(f"R^2 Score on training data: {train_score:.4f}")
    
    print("Saving model to model.pkl...")
    # Serialize and save the model
    import os
    model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "model.pkl")
    with open(model_path, 'wb') as f:
        pickle.dump(model, f)
        
    print("Machine learning model explicitly trained and saved successfully as 'model.pkl'!")

if __name__ == "__main__":
    train_dummy_model()
