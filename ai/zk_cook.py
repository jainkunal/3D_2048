from giza.zkcook import serialize_model
import xgboost as xgb

model = xgb.XGBClassifier()
model.load_model('3d_2048_xgboost_model.json')

serialize_model(model, '3d_2048_xgboost_model_zkcook.json')