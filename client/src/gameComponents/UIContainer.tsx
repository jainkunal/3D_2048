import { useDojo } from "../dojo/useDojo";
import { Button } from "@/components/ui/button";
import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";

export const UIContainer = () => {
    const {
        account: { account },
        setup: {
            client: { actions },
            clientComponents: { Player, Game },
        },
    } = useDojo();

    const player = useComponentValue(
        Player,
        getEntityIdFromKeys([BigInt(account.address)]) as Entity
    );

    const game = useComponentValue(
        Game,
        getEntityIdFromKeys([BigInt(account.address), BigInt(player ? player?.last_game_id : 1)]) as Entity
    );

    return (
        <div className="flex space-x-3 justify-between p-2 flex-wrap">
            <Button
                variant={"default"}
                onClick={async () => {
                    actions.create_game({ account });
                }}
            >
                New Game
            </Button>
            <div className="h-12 w-48 bg-white flex justify-center items-center border-2">
                Game ID: {player?.last_game_id}
            </div>
            <div className="h-12 w-48 bg-white flex justify-center items-center border-2">
                Score: {game?.score}
            </div>
        </div>
    );
};
