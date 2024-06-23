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
            clientComponents: { Player },
        },
    } = useDojo();

    const player = useComponentValue(
        Player,
        getEntityIdFromKeys([BigInt(account.address)]) as Entity
    );

    return (
        <div className="flex space-x-3 justify-between p-2 flex-wrap">
            <Button
                variant={"default"}
                onClick={() => actions.create_game({ account })}
            >
                Create Game
            </Button>
            <Button
                variant={"default"}
                onClick={() => actions.move({ account, gameId: 1, direction: 1 })}
            >
                Left
            </Button>
            <div className="h-12 w-48 bg-white flex justify-center items-center border-2">
                Game Won: {player?.games_won}
            </div>
        </div>
    );
};
