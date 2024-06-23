import numpy as np
import pandas as pd
from sklearn.calibration import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, classification_report
import xgboost as xgb
import joblib

# 1. Load the dataset
data = np.load('3d_2048_dataset.npz')
X = data['X']
y = data['y']

# 3. Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 4. Scale the features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

joblib.dump(scaler, 'standard_scaler.joblib')

# Encode the labels
label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train)
y_test_encoded = label_encoder.transform(y_test)

# Save the label encoder
joblib.dump(label_encoder, 'label_encoder.joblib')

model = xgb.XGBClassifier(
    max_depth=6,
    learning_rate=0.3,
    n_estimators=100,
    objective='multi:softprob',
    num_class=7  # 6 actions + 1 (0-based indexing)
)
model.fit(X_train_scaled, y_train_encoded)

# 8. Make predictions
y_pred = model.predict(X_test_scaled)

# 9. Evaluate the model
accuracy = accuracy_score(y_test_encoded, y_pred)
print(f"Accuracy: {accuracy:.4f}")
print("\nClassification Report:")
print(classification_report(y_test_encoded, y_pred))

# 11. Save the model
model.save_model('3d_2048_xgboost_model.json')