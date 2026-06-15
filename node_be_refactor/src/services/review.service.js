const reviewRepository = require('../repositories/review.repository');

class ReviewService {
  _formatReviewResponse(review) {
    return {
      id: review._id.toString(),
      user: review.user_id ? {
        id: review.user_id._id?.toString() || review.user_id.toString(),
        name: review.user_id.profile?.name || '',
        avatarUrl: review.user_id.profile?.avatar_url || ''
      } : null,
      court: review.court_id ? {
        id: review.court_id._id?.toString() || review.court_id.toString(),
        name: review.court_id.name || ''
      } : null,
      rating: review.rating,
      comment: review.comment,
      createdAt: review.created_at ? new Date(review.created_at).toISOString() : null
    };
  }

  async queryReviews(filters, skip = 0, limit = 20) {
    const query = {};
    
    if (filters.courtId) query.court_id = filters.courtId;
    if (filters.userId) query.user_id = filters.userId;
    if (filters.rating) query.rating = parseInt(filters.rating);

    const [reviews, total] = await Promise.all([
      reviewRepository.findMany(query, parseInt(skip), parseInt(limit)),
      reviewRepository.count(query)
    ]);

    return {
      items: reviews.map(r => this._formatReviewResponse(r)),
      total: total
    };
  }

  async createReview(data, userId) {
    const reviewData = {
      user_id: userId,
      court_id: data.courtId,
      rating: data.rating,
      comment: data.comment || ''
    };

    let newReview = await reviewRepository.create(reviewData);
    newReview = await reviewRepository.findById(newReview._id);
    
    return { review: this._formatReviewResponse(newReview) };
  }

  async deleteReview(id) {
    const deleted = await reviewRepository.deleteById(id);
    if (!deleted) throw new Error('Review not found');
    return true;
  }
}

module.exports = new ReviewService();