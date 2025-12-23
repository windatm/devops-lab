const API_URL = 'http://localhost:3000/api/tasks';

// DOM elements
const taskForm = document.getElementById('taskForm');
const taskInput = document.getElementById('taskInput');
const taskList = document.getElementById('taskList');
const loading = document.getElementById('loading');
const errorDiv = document.getElementById('error');

// Load tasks on page load
document.addEventListener('DOMContentLoaded', () => {
    loadTasks();
});

// Handle form submission
taskForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const taskName = taskInput.value.trim();
    if (!taskName) return;

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ name: taskName }),
        });

        if (!response.ok) {
            throw new Error('Không thể thêm task');
        }

        taskInput.value = '';
        loadTasks();
    } catch (error) {
        showError('Lỗi: ' + error.message);
    }
});

// Load tasks from API
async function loadTasks() {
    loading.style.display = 'block';
    errorDiv.style.display = 'none';
    taskList.innerHTML = '';

    try {
        const response = await fetch(API_URL);
        
        if (!response.ok) {
            throw new Error('Không thể tải danh sách tasks');
        }

        const tasks = await response.json();
        
        if (tasks.length === 0) {
            taskList.innerHTML = '<li class="empty">Chưa có task nào. Hãy thêm task đầu tiên!</li>';
        } else {
            tasks.forEach(task => {
                const li = document.createElement('li');
                li.innerHTML = `
                    <span class="task-id">#${task.id}</span>
                    <span class="task-name">${escapeHtml(task.name)}</span>
                    <span class="task-date">${formatDate(task.created_at)}</span>
                `;
                taskList.appendChild(li);
            });
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message + '. Đảm bảo backend service đang chạy.');
        taskList.innerHTML = '<li class="error-item">Không thể tải tasks</li>';
    } finally {
        loading.style.display = 'none';
    }
}

// Show error message
function showError(message) {
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleString('vi-VN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    });
}

