const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Tạo sẵn thư mục public/uploads nếu chưa tồn tại
const uploadDir = path.join(__dirname, '../../public/uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Chỉ cho phép tải lên định dạng hình ảnh (jpeg, jpg, png, webp)'), false);
  }
};

const uploadSingle = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 5MB limit
  fileFilter: fileFilter
}).single('file');

const uploadMultiple = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: fileFilter
}).array('files', 5); // Tối đa 5 file cùng lúc

const handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    return res.status(400).json({ success: false, message: `Lỗi Multer: ${err.message}`, code: 'UPLOAD_ERROR' });
  } else if (err) {
    return res.status(400).json({ success: false, message: err.message, code: 'UPLOAD_ERROR' });
  }
  next();
};

module.exports = {
  uploadSingle,
  uploadMultiple,
  handleUploadError
};