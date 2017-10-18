## Usage example

### 1. Install dependencies

```bash
$ pub get
$ npm install
```

### 2. Export credentials in environment, e.g.

```bash
export FIREBASE_PROJECT_ID="my-project-id"
export FIREBASE_CLIENT_EMAIL="my-admin-1231@something.iam.gserviceaccount.com"
export FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nFA6FFAA...."
export FIREBASE_DATABASE_URL="https://my-project-id.firebaseio.com"
```

### 3. Build

```bash
$ pub build node/
```

### 4. Run

```bash
$ node build/node/built_values.dart.js
```
