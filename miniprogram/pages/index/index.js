// pages/index/index.js - 首页逻辑

Page({
  /**
   * 页面的初始数据
   */
  data: {
    todayCount: 0,
    todayReminders: []
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad(options) {
    console.log('首页加载了')
    this.loadReminders()
  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow() {
    // 每次显示页面都重新加载数据
    this.loadReminders()
  },

  /**
   * 加载提醒数据
   */
  loadReminders() {
    try {
      // 从本地存储获取提醒数据
      const reminders = wx.getStorageSync('reminders') || []
      
      // 获取今天的日期
      const today = new Date()
      const todayStr = today.toISOString().split('T')[0] // YYYY-MM-DD格式
      
      // 筛选今天的提醒
      const todayReminders = reminders.filter(item => {
        return item.date === todayStr || item.date === 'today'
      })
      
      // 更新页面数据
      this.setData({
        todayCount: todayReminders.length,
        todayReminders: todayReminders.map(item => ({
          ...item,
          time: this.formatTime(item.time),
          date: item.date === todayStr ? '今天' : item.date
        }))
      })
      
      console.log('今日提醒加载完成:', todayReminders)
    } catch (error) {
      console.error('加载提醒数据失败:', error)
      wx.showToast({
        title: '加载失败',
        icon: 'error'
      })
    }
  },

  /**
   * 格式化时间显示
   */
  formatTime(timeStr) {
    if (!timeStr) return ''
    
    // 简单的时间格式化，如 "14:30"
    const time = new Date(timeStr)
    const hours = time.getHours().toString().padStart(2, '0')
    const minutes = time.getMinutes().toString().padStart(2, '0')
    return `${hours}:${minutes}`
  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage() {
    return {
      title: '微信提醒工具 - 简单好用的提醒助手',
      path: '/pages/index/index'
    }
  }
})