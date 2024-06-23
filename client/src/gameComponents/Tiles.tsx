import { useDojo } from "@/dojo/useDojo";
import { Entity, HasValue, defineSystem } from "@dojoengine/recs";
import { TileComponent } from "./TileComponent";
import { useEffect } from "react";
import { useElementStore } from "@/store";
import { gql, useApolloClient } from "@apollo/client";
import { useComponentValue } from "@dojoengine/react";
import { getEntityIdFromKeys } from "@dojoengine/utils";

const GET_TILES = gql`
  query($account: String!, $game_id: u32!) {
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
`

export const Tiles = (props: any) => {
    const {
        account: { account },
        setup: {
            clientComponents: { Player, Tile },
            world,
        },
    } = useDojo();
    const apolloClient = useApolloClient();

    const player = useComponentValue(
        Player,
        getEntityIdFromKeys([BigInt(account.address)]) as Entity
    );

    const tiles = useElementStore((state) => state.tiles);
    const update_tiles = useElementStore((state) => state.update_tiles);

    useEffect(() => {
        console.log(account.address);
        // console.log(BigInt(account.address));
        defineSystem(world, [HasValue(Tile, { game_id: player?.last_game_id })], async ({ value: [newValue] }) => {
            const { data } = await apolloClient.query({
                query: GET_TILES,
                variables: { account: account.address, game_id: player?.last_game_id }
            });
            // console.log(data);

            const entities = [];
            for (const e of data.tileModels.edges) {
                entities.push(e.node);
            }
            update_tiles(entities);
        });

    }, [Tile, account.address, apolloClient, player?.last_game_id, update_tiles, world]);

    // const v = useEntityQuery([HasValue(Tile, { game_id: 1 })], { updateOnValueChange: false })

    return (
        <>
            {
                Object.values(tiles).map((tile: any) => {
                    return <TileComponent key={tile.x + "-" + tile.y + "-" + tile.z} tile={tile} />;
                })
            }
        </>
    );
};
