class ChatbotFinancePrompt {
  static String analyzeCommand(String? input) {
    return '''
Analyze the following command and return JSON with fields:
- action: (add_transaction, edit_transaction, delete_transaction, add_category)
- params: {
  - amount: (number, transaction amount),
  - title: (string, transaction description),
  - transaction_type: ("income" or "expense"),
  - category: (string, "Salary,etc." for income, "Transport, Food, etc." for expense if not specified),
  - note: (string, optional)
}
Command: "${input ?? ''}"
Examples:
- "Lãnh lương 200" -> {action: "add_transaction", params: {amount: 200, title: "Lãnh lương", transaction_type: "income", category: "Salary"}}
- "Xe buýt 200" -> {action: "add_transaction", params: {amount: 200, title: "Xe buýt", transaction_type: "expense", category: "Transport"}}
- "Ăn sáng 20" -> {action: "add_transaction", params: {amount: 20, title: "Ăn sáng", transaction_type: "expense", category: "Food"}}
- "Mua sách 150" -> {action: "add_transaction", params: {amount: 150, title: "Mua sách", transaction_type: "expense", category: "Education"}}
- "Nhận lương 1000" -> {action: "add_transaction", params: {amount: 1000, title: "Nhận lương", transaction_type: "income", category: "Salary"}}
- "Name ( THịnh ) Trả nợ 20" -> {action: "add_transaction", params: {amount: 20, title: "Trả nợ", transaction_type: "income", category: "Other Income"}}
- "Đi đám cưới tốn 500" -> {action: "add_transaction", params: {amount: 500, title: "Đi đám cưới", transaction_type: "expense", category: "Gift"}}
- "Bán đồ cũ 100" -> {action: "add_transaction", params: {amount: 100, title: "Bán đồ cũ", transaction_type: "income", category: "Other Income"}}
- "Mua vé máy bay 2300" -> {action: "add_transaction", params: {amount: 2300, title: "Mua vé máy bay", transaction_type: "expense", category: "Travel"}}
- "Ăn trưa 50" -> {action: "add_transaction", params: {amount: 50, title: "Ăn trưa", transaction_type: "expense", category: "Food"}}
- "Nhận tiền thưởng 100" -> {action: "add_transaction", params: {amount: 100, title: "Nhận tiền thưởng", transaction_type: "income", category: "Other Income"}}
- "Mua điện thoại 1200" -> {action: "add_transaction", params: {amount: 1200, title: "Mua điện thoại", transaction_type: "expense", category: "Shopping"}}
- "tk đi du lịch 100" -> {action: "add_transaction", params: {amount: 100, title: "tk đi du lịch", transaction_type: "save", category: "Travel"}}
- "tiet kiem đi du lịch 100" -> {action: "add_transaction", params: {amount: 100, title: "tiet kiem đi du lịch", transaction_type: "save", category: "Travel"}}
''';
  }
  //info dialog
  static String dialogInfoAppBar() {
    return '''
📌 **Hướng dẫn dùng AI Money:**

**GIAO DỊCH:**
- "Ăn sáng 100k" (chi tiêu)
- "Nhận lương 10 triệu" (thu nhập)
- "Xem 5 giao dịch gần nhất"
- "Xem giao dịch hôm nay"

**DANH MỤC:**
- "Xem các danh mục chi tiêu"
- "Xem danh mục thu nhập"

**BÁO CÁO:**
- "Xem thu chi tháng này"
- "Tổng thu nhập tháng 7"
      ''';
  }

}
