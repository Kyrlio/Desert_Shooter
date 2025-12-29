// Made by PWira
// MIT License
shader_type canvas_item;

// Liquid Property
uniform float liquid_level : hint_range(0.0, 1.0) = 0.5;
uniform vec4 liquid_color : source_color = vec4(0.2, 0.5, 1.0, 0.8);
uniform vec4 foam_color : source_color = vec4(0.8, 0.9, 1.0, 0.6);

// Wave property
uniform float wave_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 20.0) = 5.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 2.0;

// Gravity property
uniform float gravity_angle : hint_range(-3.14159, 3.14159) = 0.0; // rotate in radian
uniform vec2 gravity_direction = vec2(0.0, 1.0);

// Visual property
uniform float foam_thickness : hint_range(0.0, 0.1) = 0.02;
uniform float shine_intensity : hint_range(0.0, 1.0) = 0.3;
uniform bool add_bubble = true;
uniform float bubble_scale : hint_range(0.0, 50.0) = 10.0;
uniform float bubble_speed : hint_range(0.0, 2.0) = 0.5;

// Simple Noise
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec2 rotate(vec2 v, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

void fragment() {
    vec2 uv = UV;
    vec2 centered_uv = uv - 0.5;
    vec2 rotated_uv = rotate(centered_uv, -gravity_angle);
    rotated_uv += 0.5;

    // Wave based on X in gravity coordinate
    float wave = sin(rotated_uv.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
    float surface_y = (1.0 - liquid_level) + wave;

    if (rotated_uv.y > surface_y) {
        vec4 base_color = liquid_color;

        // Ajout des vagues internes
        float internal_wave = noise(vec2(rotated_uv.x * 3.0, rotated_uv.y * 3.0 + TIME * 0.5)) * 0.1;
        base_color.rgb += vec3(internal_wave);

        // Ajout des bulles
        if (add_bubble){
            vec2 bubble_uv = rotated_uv * bubble_scale;
            bubble_uv.y += TIME * bubble_speed;
            float bubble_noise = noise(bubble_uv);
            float bubbles = step(0.95, bubble_noise);
            base_color.rgb += vec3(bubbles * 0.3);
        }

        // Ajout de la brillance
        float shine = pow(1.0 - abs(uv.x - 0.5) * 2.0, 3.0) * shine_intensity;
        base_color.rgb += vec3(shine);

        // --- MODIFICATION MAJEURE ICI ---
        
        // On calcule un facteur qui va de 0.0 (surface) à 1.0 (fond du sprite)
        float bottom_factor = (rotated_uv.y - surface_y) / (1.0 - surface_y);
        
        // 1. COULEUR : On mélange vers le BLANC (vec3(1.0)) en allant vers le fond
        base_color.rgb = mix(base_color.rgb, vec3(1.0), bottom_factor);

        // 2. TRANSPARENCE : On mélange vers l'OPAQUE (1.0) en allant vers le fond.
        // Le premier paramètre (0.1) est la transparence tout en haut (0.0 = invisible).
        // Vous pouvez changer 0.1 en 0.0 si vous voulez que le haut soit totalement invisible.
        base_color.a = mix(0.7, 1, bottom_factor);
        
        // --------------------------------

        COLOR = base_color;

    } else if (rotated_uv.y > surface_y - foam_thickness) {

        // On calcule la position dans l'épaisseur de l'écume
        // 0.0 = touche l'eau (bas), 1.0 = pointe de l'écume (haut)
        float foam_position = (surface_y - rotated_uv.y) / foam_thickness;

        // Le bruit pour donner la texture
        float foam_noise = noise(vec2(rotated_uv.x * 20.0, TIME * 2.0));
        
        // On mélange la couleur en fonction du bruit
        vec4 final_foam = mix(liquid_color, foam_color, foam_noise);

        // --- LE DÉGRADÉ ---
        // On modifie la transparence (Alpha) en fonction de la hauteur.
        // (1.0 - foam_position) signifie : Opaque en bas (1.0), Transparent en haut (0.0)
        // Le "pow(..., 0.5)" sert à rendre le dégradé plus doux, moins linéaire.
        final_foam.a *= pow(1.0 - foam_position, 0.5);
        
        // Optionnel : Si vous voulez que le haut de l'écume devienne aussi plus blanc
        final_foam.rgb = mix(final_foam.rgb, vec3(1.0), foam_position * 0.5);

        COLOR = final_foam;

    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}