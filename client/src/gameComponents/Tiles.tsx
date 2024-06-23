import { useDojo } from "@/dojo/useDojo";
import { Has, HasValue, defineSystem } from "@dojoengine/recs";
import { TileComponent } from "./Tile";
import { useEffect, useState } from "react";
import { useElementStore } from "@/store";
import { useComponentValue, useEntityQuery } from "@dojoengine/react";

export const Tiles = (props: any) => {
    const {
        account: { account },
        setup: {
            clientComponents: { Tile },
            world,
        },
    } = useDojo();

    // const tiles = useElementStore((state) => state.tiles);
    // const update_tiles = useElementStore((state) => state.update_tiles);

    // useEffect(() => {
    //     console.log(account.address);
    //     console.log(BigInt(account.address));
    //     // defineSystem(world, [HasValue(Tile, { game_id: 1 })], ({ value: [newValue] }) => {
    //     //     console.log(newValue);
    //     //     update_tiles(newValue);
    //     // });

    // }, []);
    const v = useEntityQuery([HasValue(Tile, { game_id: 1 })], { updateOnValueChange: false })
    console.log(v);

    return (
        <>
            {
                // Get all players
                Object.values(v).map((tileId: any) => {
                    return <TileComponent key={tileId} tileId={tileId} />;
                })
            }
        </>
    );
};
