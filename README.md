- Change 9h01 30/05 : add on Rules  match /transactions/users/{userEmail}/user_transactions/items/{document=**} {
  allow read, write: if request.auth != null && request.auth.token.email == userEmail;
  }![img.png](img.png)