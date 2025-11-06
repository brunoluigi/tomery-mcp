# Tomery MCP - Site Map & Navigation

## Overview
Tomery MCP is an AI-assisted meal planning application with RPG-style navigation and traditional administrative interfaces.

## Navigation Structure

### Public Routes (Unauthenticated)
```
/ (root)
├── GET / - MainController#index (Landing page)
│   └── Shows: App intro, "Enter waiting list", "Sign in" buttons
├── GET /users/new - UsersController#new (Waitlist signup)
├── POST /users - UsersController#create (Create waitlist entry)
├── GET /session/new - SessionsController#new (Sign in page)
├── POST /session - SessionsController#create (Sign in)
└── GET /auth/:provider/callback - OAuth callback (Google)
```

### Authenticated Routes - RPG Style Interface

#### Main Menu (Authenticated)
```
/ (root) - MainController#index
└── Shows RPG menu with 4 options:
    ├── Cook something → /recipes
    ├── Discover recipes → /recipes  
    ├── Plan meals → /meal_plans
    └── Manage pantry → /pantry_items
```

#### Recipes (RPG Style)
```
/recipes
├── GET /recipes - RecipesController#index (List all user recipes)
└── GET /recipes/:id - RecipesController#show (Recipe details)
```

#### Meal Plans (RPG Style)
```
/meal_plans
├── GET /meal_plans - MealPlansController#index (List meal plans)
├── GET /meal_plans/new - MealPlansController#new (Create new meal plan)
├── POST /meal_plans - MealPlansController#create
├── GET /meal_plans/:id - MealPlansController#show (Meal plan details)
└── DELETE /meal_plans/:id - MealPlansController#destroy
```

#### Pantry Items (RPG Style)
```
/pantry_items
├── GET /pantry_items - PantryItemsController#index (List pantry items)
├── GET /pantry_items/new - PantryItemsController#new (Add pantry item)
├── POST /pantry_items - PantryItemsController#create
├── PATCH/PUT /pantry_items/:id - PantryItemsController#update
└── DELETE /pantry_items/:id - PantryItemsController#destroy
```

### Authenticated Routes - Traditional "My Stuff" Interface

#### My Stuff Recipes
```
/my_stuff/recipes
├── GET /my_stuff/recipes - MyStuff::RecipesController#index
├── GET /my_stuff/recipes/:id - MyStuff::RecipesController#show
└── DELETE /my_stuff/recipes/:id - MyStuff::RecipesController#destroy
```

### Authenticated Routes - User Management (Admin Only)

#### Users
```
/users (Admin only)
├── GET /users - UsersController#index (List all users)
├── GET /users/new - UsersController#new (Waitlist signup - public)
├── POST /users - UsersController#create (Waitlist signup - public)
├── GET /users/:id/edit - UsersController#edit
├── GET /users/:id - UsersController#show
├── PATCH/PUT /users/:id - UsersController#update
├── DELETE /users/:id - UsersController#destroy
└── PUT /users/:id/toggle_activate - UsersController#toggle_activate
```

### Authenticated Routes - Session Management

#### Session
```
/session
├── GET /session - SessionsController#show (Current session info)
├── GET /session/new - SessionsController#new (Sign in - public)
├── GET /session/edit - SessionsController#edit (Edit session)
├── POST /session - SessionsController#create (Sign in - public)
├── PATCH/PUT /session - SessionsController#update
└── DELETE /session - SessionsController#destroy (Sign out)
```

### Password Reset (Public)

#### Passwords
```
/passwords
├── GET /passwords - PasswordsController#index
├── POST /passwords - PasswordsController#create (Request reset)
├── GET /passwords/new - PasswordsController#new (Request password reset)
├── GET /passwords/:token/edit - PasswordsController#edit (Reset password form)
├── GET /passwords/:token - PasswordsController#show
├── PATCH/PUT /passwords/:token - PasswordsController#update (Reset password)
└── DELETE /passwords/:token - PasswordsController#destroy
```

### API Routes

#### Model Context Protocol
```
POST /mcp - McpController#handle
```

## Top Navigation Bar (When Authenticated)

Shown in `app/views/layouts/application.html.erb`:
- **menu** → `/` (root path)
- **my stuff** → `/my_stuff/recipes`
- **current session** → `/session`
- **users** → `/users` (Admin only)
- **sign out** → DELETE `/session`

## Navigation Flow

### New User Journey
1. Land on `/` → See landing page
2. Click "Enter waiting list" → `/users/new`
3. Submit email → Added to waitlist
4. Admin activates user → User receives email
5. User signs in → `/session/new`
6. After sign in → Redirected to `/` (RPG menu)

### Authenticated User Journey (RPG Style)
1. `/` → RPG menu with 4 main options:
   - **Cook something** → `/recipes` (find recipes by pantry)
   - **Discover recipes** → `/recipes` (browse all recipes)
   - **Plan meals** → `/meal_plans` (manage weekly menu)
   - **Manage pantry** → `/pantry_items` (track ingredients)

2. From any page, user can:
   - Navigate back to menu via top nav
   - Access "My Stuff" for traditional recipe management
   - View/edit current session
   - Sign out

### Admin Journey
1. Access `/users` to manage users
2. Can toggle user activation
3. Can delete users
4. All regular user features available

## Key Controllers

- **MainController**: Landing page & RPG menu
- **RecipesController**: RPG-style recipe browsing
- **MealPlansController**: Meal planning (RPG style)
- **PantryItemsController**: Pantry management (RPG style)
- **MyStuff::RecipesController**: Traditional recipe management
- **UsersController**: User management (admin) & waitlist (public)
- **SessionsController**: Authentication
- **PasswordsController**: Password reset
- **OmniauthCallbacksController**: OAuth (Google)
- **McpController**: Model Context Protocol API

## Views Structure

- `app/views/main/` - Landing page & RPG menu
- `app/views/recipes/` - RPG-style recipe views
- `app/views/meal_plans/` - Meal plan views
- `app/views/pantry_items/` - Pantry item views
- `app/views/my_stuff/recipes/` - Traditional recipe management
- `app/views/users/` - User management
- `app/views/sessions/` - Sign in/out
- `app/views/passwords/` - Password reset
- `app/views/shared/` - Shared partials (RPG menu, dialogue boxes, etc.)

## Notes

- **RPG Style**: Main user experience uses RPG-style interface with dialogue boxes and choice cards
- **Traditional Interface**: "My Stuff" section provides traditional list/edit views
- **Authentication Required**: Most routes require authentication except public pages
- **Admin Access**: User management routes require admin privileges
- **Turbo**: Application uses Hotwire Turbo for navigation
- **Stimulus**: Interactive elements use Stimulus controllers (rpg_menu_controller, etc.)

