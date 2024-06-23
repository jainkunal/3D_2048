import { Tile } from "./TileFacade";
import { MAP_SCALE } from "@/config";

export const TileGrid = ({ rows, cols }: any) => {
    const squares = [];
    for (let row = 0; row < rows; row++) {
        for (let col = 0; col < cols; col++) {
            for (let h = 0; h < cols; h++) {
                const x = col * MAP_SCALE;
                const y = row * MAP_SCALE;
                const z = h * MAP_SCALE;

                squares.push(
                    <Tile
                        key={`${row}-${col}-${h}`}
                        position={{ x, y, z }}
                        col={col}
                        row={row}
                    />
                );
            }
        }
    }
    return <>{squares}</>;
};
