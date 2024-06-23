import * as THREE from "three";
import { useMemo } from "react";
import { MAP_SCALE } from "@/config";

export const TileComponent = (props: any) => {
    const { tile } = props;

    const vec = {
        x: tile.x * MAP_SCALE,
        y: tile.y * MAP_SCALE,
        z: tile.z * MAP_SCALE
    }

    const innerCubeGeometry = useMemo(
        () => new THREE.BoxGeometry(MAP_SCALE * 0.95, MAP_SCALE * 0.95, MAP_SCALE * 0.95),
        [MAP_SCALE]
    );

    const createTextTexture = (text: string) => {
        const canvas = document.createElement('canvas');
        canvas.width = 256;
        canvas.height = 256;
        const context = canvas.getContext('2d');
        if (context != null) {
            context.fillStyle = 'white';
            context.fillRect(0, 0, canvas.width, canvas.height);
            context.fillStyle = 'black';
            context.font = '48px Arial';
            context.textAlign = 'center';
            context.textBaseline = 'middle';
            context.fillText(text, canvas.width / 2, canvas.height / 2);
        }
        return new THREE.CanvasTexture(canvas);
    };

    const textTexture = useMemo(() => createTextTexture(tile.value), [tile.value]);

    const innerMaterials = useMemo(() => {
        const getColor = (value) => {
            switch (value) {
                case 2: return '#eee4da';
                case 4: return '#ede0c8';
                case 8: return '#f2b179';
                case 16: return '#f59563';
                case 32: return '#f67c5f';
                case 64: return '#f65e3b';
                case 128: return '#edcf72';
                case 256: return '#edcc61';
                case 512: return '#edc850';
                case 1024: return '#edc53f';
                case 2048: return '#edc22e';
                default: return '#cdc1b4'; // for empty tiles or higher values
            }
        };
        return new Array(6).fill(
            new THREE.MeshPhongMaterial({
                map: textTexture,
                color: getColor(tile.value),
                // transparent: true,
                opacity: 0.5
            })
        );
    }, [textTexture]);

    return (
        <>
            <mesh
                position={[vec.x, -vec.z, vec.y]}
                geometry={innerCubeGeometry}
                material={innerMaterials}
            />
        </>
    );
};
