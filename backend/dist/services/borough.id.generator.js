"use strict";
/**
 * Ultimate Borough ID Generator (TypeScript)
 * Takes latitude/longitude and returns a normalized 4-component borough ID
 * Format: sublocality_locality_admin-level-1_country
 */
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBoroughId = getBoroughId;
class BoroughIdGenerator {
    constructor(googleApiKey) {
        this.googleApiKey = googleApiKey;
    }
    /**
     * Main function: Get borough ID from coordinates
     */
    getBoroughId(latitude, longitude) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Get location data from Google Geocoding API
                const locationData = yield this.getLocationFromGoogle(latitude, longitude);
                // Extract and normalize components
                const components = this.parseGoogleComponents(locationData.address_components);
                // Generate borough ID
                const boroughId = this.generateBoroughId(components);
                return boroughId;
            }
            catch (error) {
                console.error('Error generating borough ID:', error);
                // Return fallback ID if everything fails
                return 'unknown_unknown_unknown_unknown';
            }
        });
    }
    /**
     * Get location data from Google Maps Geocoding API
     */
    getLocationFromGoogle(latitude, longitude) {
        return __awaiter(this, void 0, void 0, function* () {
            const url = `https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=${this.googleApiKey}`;
            const response = yield fetch(url);
            const data = yield response.json();
            if (data.status !== 'OK' || !data.results.length) {
                throw new Error(`Google Geocoding API error: ${data.status}${data.error_message ? ` - ${data.error_message}` : ''}`);
            }
            return data.results[0];
        });
    }
    /**
     * Parse Google address components into a lookup object
     */
    parseGoogleComponents(addressComponents) {
        const components = {};
        addressComponents.forEach(component => {
            component.types.forEach(type => {
                components[type] = component.long_name;
            });
        });
        return components;
    }
    /**
     * Generate the final borough ID string
     */
    generateBoroughId(components) {
        // Extract each component with fallbacks
        const sublocality = this.getSublocality(components);
        const locality = this.getLocality(components);
        const admin1 = this.getAdminLevel1(components);
        const country = this.getCountry(components);
        // Normalize each component
        const normalizedComponents = [
            this.normalizeComponent(sublocality),
            this.normalizeComponent(locality),
            this.normalizeComponent(admin1),
            this.normalizeComponent(country)
        ];
        // Join with underscores
        return normalizedComponents.join('_');
    }
    /**
     * Get sublocality (district/borough) with fallbacks
     */
    getSublocality(components) {
        return (components.sublocality_level_1 ||
            components.sublocality ||
            components.sublocality_level_2 ||
            components.neighborhood ||
            components.administrative_area_level_3 ||
            'unknown');
    }
    /**
     * Get locality (city/town) with fallbacks
     */
    getLocality(components) {
        return (components.locality ||
            components.administrative_area_level_2 ||
            components.sublocality_level_1 ||
            components.postal_town ||
            'unknown');
    }
    /**
     * Get admin level 1 (state/province) with fallbacks
     */
    getAdminLevel1(components) {
        return (components.administrative_area_level_1 ||
            components.locality ||
            'unknown');
    }
    /**
     * Get country with fallback
     */
    getCountry(components) {
        return components.country || 'unknown';
    }
    /**
     * Normalize a single component
     * - Remove accents from characters
     * - Convert to lowercase
     * - Replace spaces with dashes
     * - Remove special characters except dashes
     */
    normalizeComponent(componentName) {
        if (!componentName || componentName === 'unknown') {
            return 'unknown';
        }
        return componentName
            .toLowerCase()
            // Normalize accented characters
            .replace(/[àáâãäå]/g, 'a')
            .replace(/[èéêë]/g, 'e')
            .replace(/[ìíîï]/g, 'i')
            .replace(/[òóôõö]/g, 'o')
            .replace(/[ùúûü]/g, 'u')
            .replace(/[ç]/g, 'c')
            .replace(/[ñ]/g, 'n')
            .replace(/[ÿý]/g, 'y')
            .replace(/[ß]/g, 'ss')
            .replace(/[æ]/g, 'ae')
            .replace(/[œ]/g, 'oe')
            // Replace spaces with dashes
            .replace(/\s+/g, '-')
            // Remove all special characters except dashes and alphanumeric
            .replace(/[^a-z0-9-]/g, '')
            // Replace multiple consecutive dashes with single dash
            .replace(/-{2,}/g, '-')
            // Remove leading/trailing dashes
            .replace(/^-+|-+$/g, '')
            // Fallback if nothing remains
            || 'unknown';
    }
}
// Standalone function version
function getBoroughId(latitude, longitude) {
    return __awaiter(this, void 0, void 0, function* () {
        const googleApiKey = process.env.GOOGLE_BOOKS_API_KEY || 'api_key_not_set';
        const generator = new BoroughIdGenerator(googleApiKey);
        return yield generator.getBoroughId(latitude, longitude);
    });
}
