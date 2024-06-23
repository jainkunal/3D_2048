import { Account, AccountInterface } from "starknet";
import { DojoProvider } from "@dojoengine/core";
import { Direction } from "../../utils";

export type IWorld = Awaited<ReturnType<typeof setupWorld>>;

export interface MoveProps {
  account: Account | AccountInterface;
  gameId: number;
  direction: Direction;
}

export async function setupWorld(provider: DojoProvider) {
  function actions() {
    const create_game = async ({ account }: { account: AccountInterface }) => {
      try {
        const { transaction_hash: txHash } = await provider.execute(account, {
          contractName: "actions",
          entrypoint: "create_game",
          calldata: [],
        });
        await provider.provider.waitForTransaction(txHash);
        return txHash;
      } catch (error) {
        console.error("Error executing spawn:", error);
        throw error;
      }
    };

    const move = async ({ account, gameId, direction }: MoveProps) => {
      try {
        return await provider.execute(account, {
          contractName: "actions",
          entrypoint: "move",
          calldata: [gameId, direction],
        });
      } catch (error) {
        console.error("Error executing move:", error);
        throw error;
      }
    };
    return { create_game, move };
  }
  return {
    actions: actions(),
  };
}
