# recipes-manager-ios

An iOS application built with Swift to manage recipes. It provides functionalities such as browsing categories, searching and viewing recipes, user authentication, and managing personal profiles.

## Table of Contents

- [Features](#features)
- [Stack](#stack)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Setup Instructions](#setup-instructions)
- [Configuration](#configuration)

## Features

- Browse and search recipes by category, author, or type.
- View detailed recipe information including ingredients, instructions, and nutritional data.
- User authentication with login capabilities.
- Manage user profiles and view authored or saved recipes.
- Add, edit, and delete recipes.
- Ingredient parsing and calorie estimation.
- Image upload and preview for recipes.
- Robust network layer with GraphQL and REST API clients.

## Stack

- Swift 5+
- UIKit for user interface with Storyboards and custom views/cells.
- JWTDecode.swift for handling JWT tokens.
- EventSource for Server-Sent Events.
- Swift concurrency (async/await) for asynchronous tasks.
- GraphQL API client for communication with backend.
- REST client for standard HTTP requests.

## Installation

### Prerequisites

- macOS system with Xcode installed (version 14 or newer recommended).
- CocoaPods or Swift Package Manager (SPM) for dependency management (if modifying dependencies).
- An Apple device or Simulator running iOS 15.0+.

### Setup Instructions

1. Clone the repository:

```bash
git clone https://github.com/Shchoholiev/recipes-manager-ios.git
cd recipes-manager-ios/Recipes
```

2. Open the Xcode project:

```bash
open Recipes.xcodeproj
```

3. Build and run the project on a simulator or device.

4. To install dependencies (if needed), use Xcode’s built-in Swift Package Manager under the "File" -> "Packages" menu.

## Configuration

The app communicates with a backend API endpoint defined internally in the `HttpClient` class:

- Base API URL: `https://sh-recipes-manager-api-dev.azurewebsites.net/`

### Environment Variables / Configuration

- No external environment variables are used by default.
- JWT tokens are handled and stored securely via `JwtTokensService`.
- Image uploads are sent to a configured blob container URL inside `HelpersService`.
- API endpoints and GraphQL queries are preconfigured in the services layer.

To customize the API endpoints or add environment-specific configurations, modify the `HttpClient` and service base URLs inside code accordingly.
