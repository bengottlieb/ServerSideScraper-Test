import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

	 // Configure a PostgreSQL database
	 let postgreSQLConfig = PostgreSQLDatabaseConfig(hostname: "localhost", username: "app_collection")
	 let postgreSQL = PostgreSQLDatabase(config: postgreSQLConfig)

	 // Register the configured PostreSQL database to the database config.
	 var databases = DatabasesConfig()
	 databases.add(database: postgreSQL, as: .psql)
	 services.register(databases)
	
    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .psql)
    services.register(migrations)
}
