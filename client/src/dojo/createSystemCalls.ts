import { AccountInterface } from "starknet";
import { Entity, getComponentValue } from "@dojoengine/recs";
import { uuid } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import { Direction, updatePositionWithDirection } from "../utils";
import {
  getEntityIdFromKeys,
  getEvents,
  setComponentsFromEvents,
} from "@dojoengine/utils";
import { ContractComponents } from "./generated/contractComponents";
import type { IWorld } from "./generated/generated";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { client }: { client: IWorld },
  contractComponents: ContractComponents,
  { Game, Player, Tile }: ClientComponents
) {
  const create_game = async (account: AccountInterface) => {
    // TODO: Get the game id by reading current state
    const entityId = getEntityIdFromKeys([
      BigInt(account.address),
      BigInt(1),
    ]) as Entity;

    const gameId = uuid();
    Game.addOverride(gameId, {
      entity: entityId,
      value: {
        player: BigInt(account.address),
        game_id: 1,
        width: 4,
        height: 4,
        tile_count: 1,
        score: 0,
        state: 1,
      },
    });

    // const movesId = uuid();
    // Moves.addOverride(movesId, {
    //   entity: entityId,
    //   value: {
    //     player: BigInt(entityId),
    //     remaining: 100,
    //     last_direction: 0,
    //   },
    // });

    try {
      const { transaction_hash } = await client.actions.create_game({
        account,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );
    } catch (e) {
      console.log(e);
      Game.removeOverride(gameId);
      // Moves.removeOverride(movesId);
    } finally {
      Game.removeOverride(gameId);
      // Moves.removeOverride(movesId);
    }
  };

  const move = async (
    account: AccountInterface,
    gameId: number,
    direction: Direction
  ) => {
    const entityId = getEntityIdFromKeys([
      BigInt(account.address),
      BigInt(gameId),
    ]) as Entity;

    // const positionId = uuid();
    // Position.addOverride(positionId, {
    //   entity: entityId,
    //   value: {
    //     player: BigInt(entityId),
    //     vec: updatePositionWithDirection(
    //       direction,
    //       getComponentValue(Position, entityId) as any
    //     ).vec,
    //   },
    // });

    // const movesId = uuid();
    // Moves.addOverride(movesId, {
    //   entity: entityId,
    //   value: {
    //     player: BigInt(entityId),
    //     remaining: (getComponentValue(Moves, entityId)?.remaining || 0) - 1,
    //   },
    // });

    try {
      const { transaction_hash } = await client.actions.move({
        account,
        gameId,
        direction,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );
    } catch (e) {
      console.log(e);
      // Position.removeOverride(positionId);
      // Moves.removeOverride(movesId);
    } finally {
      // Position.removeOverride(positionId);
      // Moves.removeOverride(movesId);
    }
  };

  return {
    create_game,
    move,
  };
}
