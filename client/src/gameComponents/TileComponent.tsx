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
        return new Array(6).fill(
            new THREE.MeshPhongMaterial({
                map: textTexture,
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
