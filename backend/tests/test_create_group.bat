curl.exe -X POST http://127.0.0.1:5000/api/groups/create ^
-H "Content-Type: application/json" ^
-H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNmE1ZjM4MGExZDljYzE4OTA5YmNmYTQwIiwiZXhwIjoxNzg1MTQ2NTY3LCJpYXQiOjE3ODUwNjAxNjd9.C2CEgzWqsgm6TORNmchFPKCxWtu3b8UWHETBp1kkkY8" ^
--data-binary "@test_create_group.json"