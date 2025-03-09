# HackerNews Flutter App

A Flutter application that fetches and displays top stories from **Hacker News** using the [Hacker News API](https://github.com/HackerNews/API).

## Features

✅ Display top stories from Hacker News (`/v0/topstories.json` endpoint).  
✅ Show each story's **title, author, and creation timestamp**.  
✅ Tap on a story to **open the URL in a browser**.  
✅ Tap on an author's name to navigate to an **author details page**, which includes:
  - Author's **username**
  - **Parsed timestamp** of account creation
  - **About section** (if available)
  - A list of all the **posts submitted by the author**
✅ Optimized for **smooth performance** with **lazy loading & infinite scrolling**.
✅ Clean and **intuitive UX** inspired by Hacker News but with modern UI improvements.
✅ Uses animations and performance optimizations for a **better user experience**.

## Installation

1. Clone this repository:
   ```sh
   git clone https://github.com/yourusername/hackernews-flutter.git
   cd hackernews-flutter
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

## Dependencies

- [`dio`](https://pub.dev/packages/dio) - For making API requests.
- [`go_router`](https://pub.dev/packages/go_router) - For handling navigation.
- [`intl`](https://pub.dev/packages/intl) - For formatting timestamps.
- [`infinite_scroll_pagination`](https://pub.dev/packages/infinite_scroll_pagination) - For paginated lazy loading.
- [`url_launcher`](https://pub.dev/packages/url_launcher) - For opening URLs in the browser.

## API Reference

This app uses the **Hacker News API**, which provides data in JSON format.
Key endpoints used:

- Fetch **top stories**:
  ```sh
  GET https://hacker-news.firebaseio.com/v0/topstories.json
  ```
- Fetch **story details**:
  ```sh
  GET https://hacker-news.firebaseio.com/v0/item/{story_id}.json
  ```
- Fetch **author details**:
  ```sh
  GET https://hacker-news.firebaseio.com/v0/user/{username}.json
  ```

