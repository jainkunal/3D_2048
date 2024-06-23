import { ThreeGrid } from "./gameComponents/Three";
import "./App.css";
import { UIContainer } from "./gameComponents/UIContainer";
import { useEffect } from "react";
import { useDojo } from "./dojo/useDojo";
import { Direction } from "./utils";
import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";

function App() {
    const {
        account: { account },
        setup: {
            clientComponents: { Player },
            client: { actions },
        },
    } = useDojo();

    const player = useComponentValue(
        Player,
        getEntityIdFromKeys([BigInt(account.address)]) as Entity
    );

    useEffect(() => {
        const handleKeyDown = (event) => {
            const gameId = player?.last_game_id ?? 1;
            switch (event.key) {
                case 'ArrowUp':
                    actions.move({ account, gameId, direction: Direction.Up });
                    break;
                case 'ArrowDown':
                    actions.move({ account, gameId, direction: Direction.Down });
                    break;
                case 'ArrowLeft':
                    actions.move({ account, gameId, direction: Direction.Left });
                    break;
                case 'ArrowRight':
                    actions.move({ account, gameId, direction: Direction.Right });
                    break;
                case 'f':
                case 'F':
                    actions.move({ account, gameId, direction: Direction.Front });
                    break;
                case 'b':
                case "B":
                    actions.move({ account, gameId, direction: Direction.Back });
                    break;
                default:
                    break;
            }
        };

        window.addEventListener('keydown', handleKeyDown);

        return () => {
            window.removeEventListener("keydown", handleKeyDown);
        }
    }, [account, player?.last_game_id, account.address, actions]);

    return (
        <div className="relative w-screen h-screen flex flex-col">
            <main className="flex flex-col left-0 relative top-0 overflow-hidden grow">
                <div>
                    <UIContainer />
                </div>
                <div
                    id="canvas-container"
                    className="z-10 left-0 relative top-0 overflow-hidden grow"
                >
                    <ThreeGrid />
                </div>
            </main>
        </div>
    );
}

export default App;
