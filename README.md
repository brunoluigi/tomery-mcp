# Recipe & Meal Planning App

A Rails application that provides recipe management, pantry tracking, and meal planning capabilities through both a web interface and Model Context Protocol (MCP) integration.

Currently hosted at https://tomery.brunoluigi.com.br

## Features

### Recipe Management
- Add, update, and remove recipes with ingredients and instructions
- Store recipes with structured ingredients (name and quantity)
- View detailed recipe information

### Pantry Management
- Track pantry items with quantities
- Add and remove pantry items
- Update item quantities

### Meal Planning
- Plan meals for specific dates (breakfast, lunch, dinner, snack)
- Associate recipes with meal plans
- View and manage meal schedules

### MCP Integration
The application provides MCP tools for programmatic access to all features:
- `AddRecipeTool` - Add new recipes
- `ListRecipesTool` - List user's recipes
- `ShowRecipeTool` - Get detailed recipe information
- `UpdateRecipeTool` - Modify existing recipes
- `RemoveRecipeTool` - Delete recipes
- `AddPantryItemsTool` - Add pantry items
- `ListPantryItemsTool` - View pantry inventory
- `UpdatePantryItemQuantityTool` - Update quantities
- `RemovePantryItemsTool` - Remove pantry items
- `AddMealPlansTool` - Schedule meals
- `ListMealPlansTool` - View meal plans
- `RemoveMealPlansTool` - Cancel meal plans

## Technical Stack

- **Framework**: Rails 8.0.2
- **Database**: PostgreSQL
- **Authentication**: bcrypt for password hashing
- **Frontend**: Turbo/Stimulus with importmap
- **MCP Integration**: mcp gem and mcp-on-rails template
- **Deployment**: Kamal-ready with Docker support

## Getting Started

### Prerequisites
- Ruby (version specified in `.ruby-version`)
- PostgreSQL
- Node.js (for asset pipeline)

### Setup
```bash
# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start the server
rails server
```

The application will be available at `http://localhost:3000`

### MCP Endpoint
The MCP server is available at `/mcp` with tools for programmatic recipe and meal planning management.

## Database Schema

- **Users**: Email/password authentication
- **Sessions**: MCP token-based authentication
- **Recipes**: Title, description, ingredients (JSON), instructions (JSON)
- **PantryItems**: Name and quantity tracking
- **MealPlans**: Date-based meal scheduling with recipe associations

## Development

Run tests:
```bash
bin/rails spec test                                                                                                                                                                                                          
```

Code quality checks:
```bash
bin/rubocop
bin/brakeman
```

## Deployment

This application is configured for deployment with Kamal. See `config/deploy.yml` for deployment configuration.