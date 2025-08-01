"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPaginationSchema = createPaginationSchema;
exports.createResponseSchema = createResponseSchema;
exports.createArrayResponseSchema = createArrayResponseSchema;
exports.createPaginatedResponseSchema = createPaginatedResponseSchema;
// Utility functions for schema composition
function createPaginationSchema() {
    return {
        type: 'object',
        properties: {
            currentPage: { type: 'number', default: 1 },
            totalPages: { type: 'number', default: 1 },
            totalResults: { type: 'number', default: 0 },
            hasNextPage: { type: 'boolean', default: false },
            hasPrevPage: { type: 'boolean', default: false },
            limit: { type: 'number', default: 20 }
        }
    };
}
// Helper function to create response schemas with proper structure
function createResponseSchema(dataSchema, description = 'Success') {
    return {
        description,
        type: 'object',
        properties: dataSchema
    };
}
// Helper function to create array response schemas
function createArrayResponseSchema(itemSchema, description = 'Success') {
    return {
        description,
        type: 'array',
        items: itemSchema
    };
}
// Helper function to create paginated response schemas
function createPaginatedResponseSchema(itemsSchema, itemsKey = 'items') {
    return {
        type: 'object',
        properties: {
            [itemsKey]: {
                type: 'array',
                items: itemsSchema
            },
            pagination: createPaginationSchema()
        }
    };
}
