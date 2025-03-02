# serializers.py
from rest_framework import serializers
from .models import Ring, RingEra, RingImage

class RingEraSerializer(serializers.ModelSerializer):
    # Add fields for formatted values
    start_day_float = serializers.SerializerMethodField()
    end_day_float = serializers.SerializerMethodField()
    
    class Meta:
        model = RingEra
        fields = ['id', 'ring', 'name', 'description', 'start_day', 'end_day', 'color', 'start_day_float', 'end_day_float']
        
    def get_start_day_float(self, obj):
        # Convert to float and limit to 5 significant digits
        value = float(obj.start_day)
        return float('{:.5g}'.format(value))
        
    def get_end_day_float(self, obj):
        # Convert to float and limit to 5 significant digits
        value = float(obj.end_day)
        return float('{:.5g}'.format(value))

class RingImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = RingImage
        fields = ['id', 'ring', 'image_path', 'order']

class RingSerializer(serializers.ModelSerializer):
    eras = RingEraSerializer(many=True, read_only=True)
    images = RingImageSerializer(many=True, read_only=True)
    
    # For Flutter compatibility
    baseColor = serializers.SerializerMethodField()
    innerRadius = serializers.SerializerMethodField()
    numberOfTicks = serializers.SerializerMethodField()
    useImages = serializers.SerializerMethodField()
    imageAssets = serializers.SerializerMethodField()
    
    class Meta:
        model = Ring
        fields = ['id', 'index', 'name', 'inner_radius', 'thickness', 'number_of_ticks', 
                  'base_color', 'use_images', 'eras', 'images', 'baseColor', 'innerRadius', 
                  'numberOfTicks', 'useImages', 'imageAssets']

    def get_baseColor(self, obj):
        return obj.base_color
        
    def get_innerRadius(self, obj):
        # Convert to float and limit to 5 significant digits
        value = float(obj.inner_radius)
        # Format to 5 significant digits and convert back to float
        return float('{:.5g}'.format(value))
        
    def get_numberOfTicks(self, obj):
        return obj.number_of_ticks
        
    def get_useImages(self, obj):
        return obj.use_images
        
    def get_imageAssets(self, obj):
        image_paths = obj.images.all().order_by('order').values_list('image_path', flat=True)
        return list(image_paths)
