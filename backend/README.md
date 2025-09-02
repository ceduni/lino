# Backend

This folder contains the backend of the app. It's implemented using NodeJS and Fastify with TypeScript, and uses MongoDB as its database.

## Folder structure 

```
src
├── index.ts
├── middlewares
│   ├── auth.middleware.ts
│   └── index.ts
├── models
│   ├── bookbox.model.ts
│   ├── book.request.model.ts
│   ├── index.ts
│   ├── issue.model.ts
│   ├── notification.model.ts
│   ├── thread.model.ts
│   ├── transaction.model.ts
│   └── user.model.ts
├── routes
│   ├── admin.route.ts
│   ├── bookbox.route.ts
│   ├── book.route.ts
│   ├── index.ts
│   ├── issue.route.ts
│   ├── request.route.ts
│   ├── search.route.ts
│   ├── services.route.ts
│   ├── thread.route.ts
│   ├── transaction.route.ts
│   └── user.route.ts
├── schemas
│   ├── admin.schemas.ts
│   ├── bookbox.schemas.ts
│   ├── book.schemas.ts
│   ├── index.ts
│   ├── issue.schemas.ts
│   ├── models.schemas.ts
│   ├── request.schemas.ts
│   ├── search.schemas.ts
│   ├── services.schemas.ts
│   ├── thread.schemas.ts
│   ├── transaction.schemas.ts
│   ├── user.schemas.ts
│   └── utils.ts
├── services
│   ├── admin.service.ts
│   ├── bookbox.service.ts
│   ├── book.service.ts
│   ├── index.ts
│   ├── issue.service.ts
│   ├── notification.service.ts
│   ├── request.service.ts
│   ├── search.service.ts
│   ├── thread.service.ts
│   ├── transaction.service.ts
│   └── user.service.ts
├── tests
│   └── populateTestDatabase.ts
├── types
│   ├── book.types.ts
│   ├── common.types.ts
│   ├── index.ts
│   └── thread.types.ts
└── utilities
    ├── borough.id.generator.ts
    └── utilities.ts
```

### .env file content: 

```MONGODB_URI=uri_for_the_main_database
TEST_MONGODB_URI=uri_for_the_test_database
JWT_SECRET_KEY=jwt_secret_key
PORT=port
ADMIN_USERNAME=username_of_the_main_admin_of_the_app
GOOGLE_API_KEY=api_key_from_google_to_use_google_books_and_maps_services
BOOK_MANIPULATION_TOKEN=token_to_be_able_to_manipulate_books
```

### Docs:

See the docs at [https://lino-1.onrender.com/docs](https://lino-1.onrender.com/docs)