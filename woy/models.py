# models.py
from django.db import models

class Circle(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    days_in_cycle = models.DecimalField(null=False, default=365, max_digits=20, decimal_places=10)
    repeats = models.BooleanField(default=False)
    color = models.CharField(max_length=7, default="#0000FF")

class Era(models.Model):
    circle = models.ForeignKey(Circle, on_delete=models.CASCADE, related_name='eras')
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    start_day = models.DecimalField(null=False, default=0, max_digits=20, decimal_places=10)
    end_day = models.DecimalField(null=False, default=365, max_digits=20, decimal_places=10)
    color = models.CharField(max_length=7, default="#FF00FF")

class Event(models.Model):
    circle = models.ForeignKey(Circle, on_delete=models.CASCADE, related_name='events')
    era = models.ForeignKey(Era, on_delete=models.CASCADE, blank=True, null=True)
    name = models.CharField(max_length=200)
    image = models.ImageField(blank=True)
    description = models.TextField(blank=True)
    degree = models.DecimalField(blank=True, null=True, max_digits=20, decimal_places=10)
    day = models.DecimalField(blank=True, null=True, max_digits=20, decimal_places=10)

class Ring(models.Model):
    index = models.IntegerField()
    name = models.CharField(max_length=200)
    inner_radius = models.DecimalField(null=False, default=50, max_digits=20, decimal_places=10)
    thickness = models.DecimalField(null=False, default=20, max_digits=20, decimal_places=10)
    number_of_ticks = models.IntegerField(default=365)
    base_color = models.CharField(max_length=7, default="#00FF00")
    use_images = models.BooleanField(default=False)

class RingEra(models.Model):
    ring = models.ForeignKey(Ring, on_delete=models.CASCADE, related_name='eras')
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    start_day = models.DecimalField(null=False, default=0, max_digits=20, decimal_places=10)
    end_day = models.DecimalField(null=False, default=365, max_digits=20, decimal_places=10)
    color = models.CharField(max_length=7, default="#FF00FF")

class RingImage(models.Model):
    ring = models.ForeignKey(Ring, on_delete=models.CASCADE, related_name='images')
    image_path = models.CharField(max_length=500)
    order = models.IntegerField(default=0)
