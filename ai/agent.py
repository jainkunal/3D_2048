import asyncio
import joblib
from starknet_py.net.account.account import Account
from starknet_py.net.signer.stark_curve_signer import KeyPair
from starknet_py.net.full_node_client import FullNodeClient
from dotenv import load_dotenv
import types

from starknet_py.net.client_models import Call
from gql import gql, Client
from gql.transport.requests import RequestsHTTPTransport
import numpy as np
import xgboost as xgb
from starknet_py.common import int_from_bytes

load_dotenv()

GAME_ID = 1
ACCOUNT = "0x406d442845859980b21a20b42a4c9fa7e175f08671539f1a8aac3b0f6755973"
PRIVATE_KEY = "0x4bdb8ef1243075cfd829ed2ab399f3ea2fec0b801fbabd358d954fff5dfc1e0"

NODE_URL = "https://api.cartridge.gg/x/v0/katana"
GRAPHQL_ENDPOINT = "https://api.cartridge.gg/x/v0/torii/graphql"
NODE_URL = "http://localhost:5050"
GRAPHQL_ENDPOINT = "http://localhost:8080/graphql"

strk_client = FullNodeClient(node_url=NODE_URL)

transport = RequestsHTTPTransport(url=GRAPHQL_ENDPOINT)

# Create a GraphQL client
gql_client = Client(transport=transport, fetch_schema_from_transport=True)

query = gql(
    """
query($account: ContractAddress!, $game_id: u32!) {
    tileModels(where: {player: $account, game_id: $game_id}, limit:100) {
      edges {
        node {
          player
          game_id
          tile_id
          x
          y
          z
          value
        }
      }
    }
  }
"""
)


def process_game_state(tile_data):
    # Initialize a 4x4x4 grid with zeros
    grid = np.zeros((4, 4, 4), dtype=int)

    # Fill in the grid with the provided tile values
    for tile in tile_data:
        x, y, z = tile["x"], tile["y"], tile["z"]
        value = tile["value"]
        grid[x, y, z] = value

    # Flatten the grid to a 1D array of size 64
    flattened_grid = grid.flatten()

    return flattened_grid


def get_data():
    result = gql_client.execute(query, {"account": ACCOUNT, "game_id": GAME_ID})
    tiles = []
    for node in result["tileModels"]["edges"]:
        # print(node["node"])
        tiles.append(node["node"])

    processed_data = process_game_state(tiles)

    # Load the saved StandardScaler
    scaler = joblib.load("standard_scaler.joblib")

    # Apply the scaling
    scaled_data = scaler.transform([processed_data])

    return scaled_data


async def play():
    account = Account(
        address=ACCOUNT,
        client=strk_client,
        key_pair=KeyPair.from_private_key(PRIVATE_KEY),
        chain=int_from_bytes(b"KATANA"),  # TODO: Check in katana
    )

    # ======= Create spurious function to please GizaAgent
    def upper_method(self):
        return "ACC"

    account.upper = types.MethodType(upper_method, account)
    # ======= End

    scaled_data = get_data()
    model = xgb.XGBClassifier()
    model.load_model("3d_2048_xgboost_model.json")

    label_encoder = joblib.load("label_encoder.joblib")
    prediction_encoded = model.predict(scaled_data)
    prediction_proba = model.predict_proba(scaled_data)

    prediction = label_encoder.inverse_transform(prediction_encoded)
    # print("\nModel prediction (decoded):")
    # print(prediction)
    print("\nPrediction probabilities:")
    print(prediction_proba)

    actions = ["Left", "Right", "Up", "Down", "Back", "Front"]
    predicted_action = actions[prediction[0] - 1]  # -1 because actions are 1-indexed
    print(f"\nPredicted best move: {predicted_action}")

    # MODEL_ID = 840
    # VERSION_ID = 2
    # ENDPOINT_ID = 336
    # model = GizaModel(
    #     id=MODEL_ID,
    #     version=VERSION_ID,
    # )

    await account.execute_v1(
        calls=[
            Call(
                to_addr=int(
                    0x38D4AD3EB3C1FA648214F2CDED353832B6AE8D051110E52FBF4451E4F5C3883
                ),
                selector=int(
                    0x239E4C8FBD11B680D7214CFC26D1780D5C099453F0832BEB15FD040AEBD4EBB
                ),
                calldata=[
                    GAME_ID,
                    prediction[0].item(),
                ],
            )
        ],
        max_fee=170351367819270,
    )


if __name__ == "__main__":
    asyncio.run(play())
