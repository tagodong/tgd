function image_score = imScore(img,ref)
    
    image_score = immse(img,ref)-log((1.0+ssim(img,ref))/2);

end