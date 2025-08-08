// Utility functions for schema composition
export function createPaginationSchema() {
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
export function createResponseSchema(dataSchema: any, description: string = 'Success') {
    return {
        description,
        type: 'object',
        properties: dataSchema
    };
}

// Helper function to create array response schemas
export function createArrayResponseSchema(itemSchema: any, description: string = 'Success') {
    return {
        description,
        type: 'array',
        items: itemSchema
    };
}

// Helper function to create paginated response schemas
export function createPaginatedResponseSchema(itemsSchema: any, itemsKey: string = 'items') {
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
