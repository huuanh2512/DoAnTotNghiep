class UploadService {
  _formatFileResponse(file, req) {
    const configuredBaseUrl = process.env.UPLOAD_PUBLIC_BASE_URL?.replace(/\/+$/, '');
    const baseUrl = configuredBaseUrl || `${req.protocol}://${req.get('host')}`;
    return {
      filename: file.filename,
      originalName: file.originalname,
      mimeType: file.mimetype,
      size: file.size,
      url: `${baseUrl}/uploads/${file.filename}`
    };
  }

  async processSingleUpload(file, req) {
    return { file: this._formatFileResponse(file, req) };
  }

  async processMultipleUpload(files, req) {
    const formattedFiles = files.map(file => this._formatFileResponse(file, req));
    return { files: formattedFiles };
  }
}

module.exports = new UploadService();
