# models.py
from django.db import models
from django.contrib.auth.models import User

class Ring(models.Model):
    index = models.IntegerField()
    name = models.CharField(max_length=200)
    inner_radius = models.DecimalField(null=False, default=50, max_digits=20, decimal_places=10)
    thickness = models.DecimalField(null=False, default=20, max_digits=20, decimal_places=10)
    number_of_ticks = models.IntegerField(default=365)
    base_color = models.CharField(max_length=7, default="#00FF00")
    use_images = models.BooleanField(default=False)
    is_public = models.BooleanField(default=True)
    created_by = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL, related_name='created_rings')

class RingEra(models.Model):
    ring = models.ForeignKey(Ring, on_delete=models.CASCADE, related_name='eras')
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    start_day = models.DecimalField(null=False, default=0, max_digits=20, decimal_places=10)
    end_day = models.DecimalField(null=False, default=365, max_digits=20, decimal_places=10)
    color = models.CharField(max_length=7, default="#FF00FF")

class RingImage(models.Model):
    ring = models.ForeignKey(Ring, on_delete=models.CASCADE, related_name='images')
    image_path = models.CharField(max_length=255)
    order = models.IntegerField(default=0)

class UserRingPreference(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='ring_preferences')
    ring = models.ForeignKey(Ring, on_delete=models.CASCADE, related_name='user_preferences')
    display_order = models.IntegerField(default=0)

    class Meta:
        unique_together = ('user', 'ring')
        ordering = ['display_order']
