# Các chức năng chính
- Đăng nhập từ bên thứ ba (Facebook, Google).
- Xác thực và uỷ quyền cho người dùng.
- Người dùng có thể đăng, bình luận về bài viết, trả lời bình luận.
- Có thể thả reaction bài viết như Facebook.
- Người dùng có thể báo cáo và chặn người dùng khác.
- Chức năng xuất CSV.
- Chức năng thông báo thời gian thực.
- Chức năng Chat, gửi ảnh và tệp cho nhau.
- Tự động chạy CI khi Deploy Heroku.
- Bot thống kê web hằng ngày và gửi trong Slack.
## Chạy server
```
rails db:migrate
rails db:seed
rails s
```
## Chạy chức năng chat
```
bundle exec sidekiq
```
