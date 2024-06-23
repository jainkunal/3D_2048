import { ThreeGrid } from "./gameComponents/Three";
import "./App.css";
import { UIContainer } from "./gameComponents/UIContainer";
import { useEffect } from "react";
import { useDojo } from "./dojo/useDojo";
import { Direction } from "./utils";

function App() {
    const {
        account: { account },
        setup: {
            client: { actions },
        },
    } = useDojo();

    useEffect(() => {
        const handleKeyDown = (event) => {
            switch (event.key) {
                case 'ArrowUp':
                    actions.move({ account, gameId: 1, direction: Direction.Up });
                    break;
                case 'ArrowDown':
                    actions.move({ account, gameId: 1, direction: Direction.Down });
                    break;
                case 'ArrowLeft':
                    actions.move({ account, gameId: 1, direction: Direction.Left });
                    break;
                case 'ArrowRight':
                    actions.move({ account, gameId: 1, direction: Direction.Right });
                    break;
                case 'f':
                case 'F':
                    actions.move({ account, gameId: 1, direction: Direction.Front });
                    break;
                case 'b':
                case "B":
                    actions.move({ account, gameId: 1, direction: Direction.Back });
                    break;
                default:
                    break;
            }
        };

        window.addEventListener('keydown', handleKeyDown);

        return () => {
            window.removeEventListener("keydown", handleKeyDown);
        }
    }, [actions]);

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
