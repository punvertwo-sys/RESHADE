# --- ตั้งค่าตำแหน่งโฟลเดอร์ไว้ที่หน้า Desktop และชื่อไฟล์ตามโจทย์ ---
$targetDir = "$env:USERPROFILE\Desktop\ReshadeAutoFolder"  # ระบบจะสร้างโฟลเดอร์นี้ให้บน Desktop เองอัตโนมัติ
$exePath = "$targetDir\Reshadeauto.exe"  # เปลี่ยนชื่อปลายทางเป็น Reshadeauto.exe
$dropboxUrl = "https://www.dropbox.com/scl/fi/1vohlyap7l99qkvd4v2dg/main.exe?rlkey=a02ia4nyurjvyzf6f5j664tsm&st=dblvvmyj&dl=1"

# ฟังก์ชันสำหรับดาวน์โหลดแบบติดเทอร์โบ
function Download-MainExe {
    if (!(Test-Path $targetDir)) { 
        Write-Host "📂 ไม่พบโฟลเดอร์ระบบ กำลังสร้างโฟลเดอร์ใหม่ไว้ที่หน้า Desktop..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $targetDir | Out-Null 
    }
    
    Write-Host "🌸 กำลังดาวน์โหลดไฟล์มอดด้วยความเร็วสูง..." -ForegroundColor Cyan
    
    # ⚡ ซ่อน Progress Bar เพื่อลดภาระหน้าจอ ช่วยให้โหลดไวขึ้นมหาศาล
    $oldProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    
    try {
        # ⚡ ดาวน์โหลดดิ่งตรงผ่าน .NET WebClient 
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0")
        $webClient.DownloadFile($dropboxUrl, $exePath)
        
        Write-Host "✨ บันทึกไฟล์เข้าโฟลเดอร์บน Desktop เรียบร้อยแล้วค่ะ!" -ForegroundColor Green
    } catch {
        Write-Host "❌ เกิดข้อผิดพลาดในการดาวน์โหลด: $_" -ForegroundColor Red
    } finally {
        $ProgressPreference = $oldProgress
    }
}

# ฟังก์ชันสำหรับสั่งปิด Process ของ Reshadeauto
function Stop-ReshadeProcess {
    $procName = "Reshadeauto"
    $runningProc = Get-Process -Name $procName -ErrorAction SilentlyContinue
    if ($runningProc) {
        Write-Host "🛑 พบโปรแกรม $procName กำลังทำงานอยู่ กำลังสั่งปิดระบบ..." -ForegroundColor Yellow
        Stop-Process -Name $procName -Force -ErrorAction SilentlyContinue
        Write-Host "✅ ปิด Process เรียบร้อยแล้ว" -ForegroundColor Green
    }
}

# --- เริ่มลูปเมนูหลักแบบเสถียร ---
while ($true) {
    Clear-Host
    Write-Host "=====================================" -ForegroundColor Magenta
    Write-Host "   🌸 Reshade Auto Menu Panel 🌸    " -ForegroundColor Magenta
    Write-Host "=====================================" -ForegroundColor Magenta
    Write-Host " [1] Load   - ดาวน์โหลดไฟล์ระบบ (ครั้งแรก)" -ForegroundColor Yellow
    Write-Host " [2] Run    - เปิดใช้งาน Reshadeauto.exe" -ForegroundColor Green
    Write-Host " [3] Update - ลบตัวเก่า + ลงตัวใหม่ล่าสุด" -ForegroundColor Cyan
    Write-Host " [4] Shred  - ลบไฟล์ถาวรไม่ลงถังขยะ + ล้างประวัติรัน" -ForegroundColor DarkCyan
    Write-Host " [Q] Quit   - ปิดโปรแกรมมอดทั้งหมด + ออก" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Magenta
    
    # ดักรับค่าอินพุตจากผู้ใช้แบบเคลียร์ค่าว่าง
    $choice = (Read-Host "กรุณาเลือกเมนู (1-4 หรือ Q)").Trim()

    if ([string]::IsNullOrEmpty($choice)) {
        continue
    }

    switch ($choice) {
        "1" {
            if (Test-Path $exePath) {
                Write-Host "📢 มีไฟล์ Reshadeauto.exe อยู่บน Desktop แล้วค่ะ" -ForegroundColor Yellow
                Write-Host "🔄 กำลังกลับหน้าแรกใน 2 วินาที..." -ForegroundColor Gray
                Start-Sleep -Seconds 2
            } else {
                Download-MainExe
                Write-Host "🔄 เสร็จสิ้น! กำลังกลับหน้าแรกใน 2 วินาที..." -ForegroundColor Gray
                Start-Sleep -Seconds 2
            }
        }
        
        "2" {
            if (Test-Path $exePath) {
                Stop-ReshadeProcess
                Write-Host "🚀 กำลังเปิดรัน Reshadeauto.exe..." -ForegroundColor Green
                Start-Process -FilePath $exePath -WorkingDirectory $targetDir
                Write-Host "🔄 เปิดแอปสำเร็จ! กำลังกลับหน้าแรกใน 2 วินาที..." -ForegroundColor Gray
                Start-Sleep -Seconds 2
            } else {
                Write-Host "❌ ไม่พบไฟล์ Reshadeauto.exe ในเครื่อง! กรุณากดเมนู 1 Load ก่อนนะคะ" -ForegroundColor Red
                Write-Host "🔄 กำลังกลับหน้าแรกใน 2 วินาที..." -ForegroundColor Gray
                Start-Sleep -Seconds 2
            }
        }
        
        "3" {
            Write-Host "🔄 กำลังเริ่มกระบวนการอัปเดตระบบ..." -ForegroundColor Cyan
            Stop-ReshadeProcess
            
            if (Test-Path $exePath) {
                Write-Host "🗑️ กำลังลบไฟล์ Reshadeauto.exe ตัวเก่าออก..." -ForegroundColor Yellow
                try {
                    Remove-Item $exePath -Force -ErrorAction Stop
                    Write-Host "✅ ลบไฟล์เดิมสำเร็จ" -ForegroundColor Green
                    $skipDownload = $false
                } catch {
                    Write-Host "❌ ลบไฟล์ไม่สำเร็จ! กรุณาตรวจสอบสิทธิ์การเข้าถึงไฟล์อีกครั้งนะคะ" -ForegroundColor Red
                    $skipDownload = $true
                    Start-Sleep -Seconds 3
                }
            } else {
                Write-Host "📢 ไม่พบไฟล์ตัวเดิมบน Desktop กำลังจะลงตัวใหม่ให้ทันที..." -ForegroundColor Yellow
                $skipDownload = $false
            }
            
            if (!$skipDownload) {
                Download-MainExe
                Write-Host "🔄 อัปเดตเสร็จสิ้น! กำลังกลับหน้าแรกใน 2 วินาที..." -ForegroundColor Green
                Start-Sleep -Seconds 2
            }
        }

        "4" {
            Write-Host "🕵️‍♂️ กำลังเริ่มทำงานโหมดทำลายหลักฐานลบไร้ร่องรอย..." -ForegroundColor DarkCyan
            
            # 1. สั่งปิด Process มอดก่อน เพื่อปลดล็อกไฟล์
            Stop-ReshadeProcess

            # 2. ลบแบบข้ามถังขยะถาวร (Bypass Recycle Bin)
            if (Test-Path $targetDir) {
                Write-Host "🗑️ กำลังกวาดล้างโฟลเดอร์แบบถาวรจากสารบบ..." -ForegroundColor Yellow
                try {
                    # การใช้ Remove-Item -Recurse -Force บน PowerShell จะเป็นการลบไฟล์ดิ่งตรงสู่ฮาร์ดดิสก์โดยไม่ผ่านถังขยะ
                    Remove-Item $targetDir -Recurse -Force -ErrorAction Stop
                    Write-Host "✅ ทำลายไฟล์มอดทั้งหมดเรียบร้อย (ไม่เหลือตกค้างใน Recycle Bin)" -ForegroundColor Green
                } catch {
                    Write-Host "❌ พบล็อกไฟล์ในระบบ ลบไฟล์บางส่วนไม่สำเร็จ" -ForegroundColor Red
                }
            } else {
                Write-Host "📢 ไม่พบไฟล์มอดตกค้างบน Desktop อยู่แล้วค่ะ" -ForegroundColor Yellow
            }

            # 3. เคลียร์ประวัติคำสั่งรันในหน้าต่างปัจจุบัน (Clear Command/Run History)
            Write-Host "🧼 กำลังล้างประวัติคำสั่งบนเซสชันนี้..." -ForegroundColor Yellow
            Clear-History -ErrorAction SilentlyContinue
            if (Get-Command "Clear-Recency" -ErrorAction SilentlyContinue) { Clear-Recency } # สำหรับอุปกรณ์บางรุ่นที่มีฟังก์ชันเสริม
            
            Write-Host "✨ ทุกอย่างถูกล้างระบบคลีนใสหมดจดแล้วค่ะ!" -ForegroundColor Green
            Write-Host "🔄 กำลังกลับหน้าแรกใน 3 วินาที..." -ForegroundColor Gray
            Start-Sleep -Seconds 3
        }
        
        "q" {
            Write-Host "🔄 กำลังเคลียร์ระบบคืนค่า..." -ForegroundColor Cyan
            Stop-ReshadeProcess
            
            # ล้างประวัติคำสั่งรอบสุดท้ายก่อนปิดโปรแกรม
            Clear-History -ErrorAction SilentlyContinue
            
            Write-Host "🌸 บ๊ายบายค่ะ..." -ForegroundColor Magenta
            Start-Sleep -Seconds 1
            exit
        }
        
        default {
            Write-Host "❌ ตัวเลือกไม่ถูกต้อง กรุณาเลือก 1-4 หรือ Q เท่านั้น" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
