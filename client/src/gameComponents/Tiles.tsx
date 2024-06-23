import { useDojo } from "@/dojo/useDojo";
import { HasValue, defineSystem } from "@dojoengine/recs";
import { TileComponent } from "./TileComponent";
import { useEffect } from "react";
import { useElementStore } from "@/store";
import { gql, useApolloClient } from "@apollo/client";

const GET_TILES = gql`
  query {
    tileModels(limit:100) {
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
            clientComponents: { Tile },
            world,
        },
    } = useDojo();
    const apolloClient = useApolloClient();

    const tiles = useElementStore((state) => state.tiles);
    const update_tiles = useElementStore((state) => state.update_tiles);

    useEffect(() => {
        // console.log(account.address);
        // console.log(BigInt(account.address));
        defineSystem(world, [HasValue(Tile, { game_id: 1 })], async ({ value: [newValue] }) => {
            const { data } = await apolloClient.query({
                query: GET_TILES,
            });

            const entities = [];
            for (const e of data.tileModels.edges) {
                entities.push(e.node);
            }
            update_tiles(entities);
        });

    }, []);

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
