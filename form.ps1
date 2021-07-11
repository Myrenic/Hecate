#########################################################################
#                        Add shared_assemblies                          #
#########################################################################


[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')      | out-null  
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null


#########################################################################
#                        Load Main Panel                                #
#########################################################################

$Global:pathPanel = split-path -parent $MyInvocation.MyCommand.Definition

function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}


$XamlMainWindow=LoadXaml($pathPanel+"\form.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)


#########################################################################
#                        HAMBURGER VIEWS                                #
#########################################################################

#******************* Target View  *****************

$HamburgerMenuControl = $Form.FindName("HamburgerMenuControl")

$ControlView   = $Form.FindName("ControlView") 
$NewFirmHireView  = $Form.FindName("NewFirmHire")
$InternalView  = $Form.FindName("InternalView") 
$AboutView     = $Form.FindName("AboutView") 

#******************* Load Other Views  *****************
$viewFolder = $pathPanel +"\views"

$XamlChildWindow = LoadXaml($viewFolder+"\Home.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$HomeXaml        = [Windows.Markup.XamlReader]::Load($Childreader)


$XamlChildWindow = LoadXaml($viewFolder+"\Internal.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$InternalXaml    = [Windows.Markup.XamlReader]::Load($Childreader)


$XamlChildWindow = LoadXaml($viewFolder+"\NewFirmHire.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$NewFirmHireXaml    = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\About.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$AboutXaml       = [Windows.Markup.XamlReader]::Load($Childreader)

    
$ControlView.Children.Add($HomeXaml)       | Out-Null
$NewFirmHireView.Children.Add($NewFirmHireXaml)  | Out-Null    
$InternalView.Children.Add($InternalXaml)  | Out-Null      
$AboutView.Children.Add($AboutXaml)        | Out-Null

#******************************************************
# Initialize with the first value of Item Section *****
#******************************************************

$HamburgerMenuControl.SelectedItem = $HamburgerMenuControl.ItemsSource[0]


#########################################################################
#                           CONTROL  VIEW                               #
#########################################################################

$pgTextBox       = $HomeXaml.FindName("pgTextBox") 
$btnUpdate       = $HomeXaml.FindName("btnUpdate") 
$pgProgressbar   = $HomeXaml.FindName("pgProgressbar") 

$btnUpdate.add_Click({
    
    try{
    $isInt32 = $true
    [int]$newValue = $pgTextBox.Text
    }catch{
    $isInt32 = $false
    }

    If( $newValue -ge 0 -and $newValue -le 100 -and $isInt32 ){
        
        $pgProgressbar.Value = $newValue
    }
    else{
        $result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Progressbar","Please specify a number betwen 0 and 100.")
    } 
})

#########################################################################
#                           INTERNAL VIEW                               #
#########################################################################

$btnOpenAsyncDialg   = $InternalXaml.FindName("btnOpenAsyncDialg") 
$btnOpenAsyncDialg.add_Click({
 
  # Show async message dialog
  [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form,"Some title","AsyncMessage Dialog here") 

})

#########################################################################
#                           New Firm Hire                               #
#########################################################################


# Dialog type button
$btnSearch = $NewFirmHireXaml.FindName("btnSearchUser") 
$btnSubmit = $NewFirmHireXaml.FindName("btnSubmit") 
$pgProgressbar = $NewFirmHireXaml.FindName("pgProgressbar")

# input textboxes
$dialgUserName = $NewFirmHireXaml.FindName("dialgUserName") 
$btnAddToMainGroups = $NewFirmHireXaml.FindName("btnAddToMainGroups") 
$dialgManagerName = $NewFirmHireXaml.FindName("dialgManagerName") 

$pgProgressbar.visibility = "Hidden"

$btnSearch.add_Click({
    $username = $dialgUserName.Text
        If ($username){ 
        $dialgUserName.Foreground = "Green"
        $dialgUserName.IsReadOnly = "True"

    }
    else{
        $dialgUserName.Foreground = "Red"
    }
})

$btnSubmit.add_Click({
    $dialgManagerName
        $ManagerUsername = $dialgManagerName.Text
        If ($ManagerUsername){ 
            $dialgManagerName.Foreground = "Green"
            $dialgManagerName.IsReadOnly = "True"
            # OK CANCEL Style
            $okAndCancel = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
            # Metro Dialog Settings
            $settings = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
            $settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme

            # show ok/cancel message
            $result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Confirmation","Do you really want to stage $($dialgUserName.Text)?",$okAndCancel, $settings)
            If ($result -eq "Affirmative"){ 
                $pgProgressbar.visibility = "Visible"
             }
            else{
                # OK ONLY
                $okOnly      = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative

                # Metro Dialog Settings
                $settings = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
                $settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme

                # show ok/cancel message
                $result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Canceled","Staging $($dialgUserName.Text)'s account has been stopped.",$okOnly, $settings)
       
            }
    }
    else{
        $dialgManagerName.Foreground = "Red"
    }
})


# # === Open Normal Message Dialog  ===
# $btnOpenDialg.add_Click({
   
#     # OK CANCEL Style
#     $okAndCancel = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
#     # OK ONLY
#     $okOnly      = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative

#     # Metro Dialog Settings
#     $settings = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
#     $settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme

#     # show ok/cancel message
#     $result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Title","Your message. ",$okAndCancel, $settings)
    
#     #$result is a string
#     $dialgResult.Text = $result

#     If ($result -eq "Affirmative"){ 
#         $dialgResult.Foreground = "Green"
#     }
#     else{
#         $dialgResult.Foreground = "Red"
#     }

# })

# # === Open Login Metro Dialog  ===

# $btnOpenLoginDialg.add_Click({
  
#     # Show external login dialog
#     $result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalLoginExternal($Form,"DEV4SYS Login:","You know what to do :)") 
  
#     #result is an object 
#     $dialgResultUser.Text = $result.Username
#     $dialgResultPwd.Text  = $result.Password

# })


#########################################################################
#                        HAMBURGER EVENTS                               #
#########################################################################

#******************* Items Section  *******************

$HamburgerMenuControl.add_ItemClick({
    
   $HamburgerMenuControl.Content = $HamburgerMenuControl.SelectedItem
   $HamburgerMenuControl.IsPaneOpen = $false

})

#******************* Options Section  *******************

$HamburgerMenuControl.add_OptionsItemClick({

    $HamburgerMenuControl.Content = $HamburgerMenuControl.SelectedOptionsItem
    $HamburgerMenuControl.IsPaneOpen = $false

})



#########################################################################
#                        Show Dialog                                    #
#########################################################################

$Form.add_MouseLeftButtonDown({
   $_.handled=$true
   $this.DragMove()
})
     


$Form.ShowDialog() | Out-Null
  
