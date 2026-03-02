// app.js - 小程序入口文件

App({
  // 小程序启动时执行
  onLaunch() {
    console.log('小程序启动了！')
    
    // 检查本地存储中是否有提醒数据
    try {
      const reminders = wx.getStorageSync('reminders')
      if (!reminders) {
        // 如果没有数据，初始化一个空数组
        wx.setStorageSync('reminders', [])
        console.log('初始化提醒数据成功')
      }
    } catch (error) {
      console.error('获取存储数据失败:', error)
    }
  },
  
  // 全局数据，可以在所有页面访问
  globalData: {
    userInfo: null,
    reminders: []
  }
})