from django.contrib import admin
from django import forms
from .models import Ring, RingEra, RingImage, UserRingPreference

# Ring admin
class RingAdminForm(forms.ModelForm):
    class Meta:
        model = Ring
        fields = '__all__'

    base_color = forms.CharField(widget=forms.TextInput(attrs={'type': 'color'}))

class RingEraAdminForm(forms.ModelForm):
    class Meta:
        model = RingEra
        fields = '__all__'

    color = forms.CharField(widget=forms.TextInput(attrs={'type': 'color'}))

class RingEraInline(admin.TabularInline):
    model = RingEra
    form = RingEraAdminForm
    extra = 1
    fields = ['name', 'description', 'start_day', 'end_day', 'color']

class RingImageInline(admin.TabularInline):
    model = RingImage
    extra = 1
    fields = ['image_path', 'order']

@admin.register(Ring)
class RingAdmin(admin.ModelAdmin):
    model = Ring
    form = RingAdminForm
    list_display = ('name', 'index', 'number_of_ticks', 'base_color', 'use_images', 'is_public', 'created_by')
    list_filter = ('is_public',)
    search_fields = ('name',)
    inlines = [RingEraInline, RingImageInline]

@admin.register(RingEra)
class RingEraAdmin(admin.ModelAdmin):
    list_display = ('name', 'ring', 'start_day', 'end_day', 'color')
    list_filter = ('ring',)
    search_fields = ('name',)

@admin.register(RingImage)
class RingImageAdmin(admin.ModelAdmin):
    list_display = ('ring', 'image_path', 'order')
    list_filter = ('ring',)

@admin.register(UserRingPreference)
class UserRingPreferenceAdmin(admin.ModelAdmin):
    list_display = ('user', 'ring', 'display_order')
    list_filter = ('user',)
    search_fields = ('user__username', 'ring__name')
