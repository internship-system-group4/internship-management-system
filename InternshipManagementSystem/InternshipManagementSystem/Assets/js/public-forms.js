(function () {
 'use strict';
 function field(id){return document.getElementById(id);}
 // The message for one required field, or '' when it is locally valid. Pages may override the wording with
 // data-required-message, data-invalid-message (email) and data-short-message (minlength).
 function fieldMessage(input){
  var value=input.value.trim();
  if(!value) return input.getAttribute('data-required-message')||window.uimsT('FieldRequired');
  if(input.type==='email'&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) return input.getAttribute('data-invalid-message')||window.uimsT('FieldEmail');
  if(input.minLength>0&&value.length<input.minLength) return input.getAttribute('data-short-message')||window.uimsT('FieldMinLength',input.minLength);
  return '';
 }
 window.publicFieldMessage=fieldMessage;
 function validate(form){
  if(form.getAttribute('data-submitting')==='true')return false;
  var first=null,valid=true;
  form.querySelectorAll('[data-public-required]').forEach(function(input){
   var message=fieldMessage(input),error=field(input.getAttribute('aria-describedby').split(' ')[0]);
   if(error)error.textContent=message;
   input.setAttribute('aria-invalid',String(!!message));
   if(message){valid=false;if(!first)first=input;}
  });
  if(first)first.focus();
  if(valid){
   form.setAttribute('data-submitting','true');form.setAttribute('aria-busy','true');
   var button=form.querySelector('input[type="submit"]'),status=form.querySelector('[data-submit-status]');
   if(button){button.dataset.originalText=button.value;button.setAttribute('aria-disabled','true');button.value=form.dataset.publicForm==='contact'?window.uimsT('Sending'):form.dataset.publicForm==='login'?window.uimsT('SigningIn'):window.uimsT('RequestingReset');}
   if(status)status.textContent=window.uimsT('SendingStatus');
  }
  return valid;
 }
 window.validateLogin=function(){return validate(document.querySelector('[data-public-form]'));};
 window.validateEmail=window.validateLogin;
 window.validateContact=window.validateLogin;
 document.querySelectorAll('[data-public-required]').forEach(function(input){
  input.addEventListener('input',function(){input.removeAttribute('aria-invalid');var error=field(input.getAttribute('aria-describedby').split(' ')[0]);if(error)error.textContent='';});
 });
 var toggle=field('toggleButton');
 if(toggle)toggle.addEventListener('click',function(){
  var password=field(toggle.getAttribute('aria-controls')),show=password.type==='password';
  password.type=show?'text':'password';toggle.textContent=show?window.uimsT('Hide'):window.uimsT('Show');
  toggle.setAttribute('aria-pressed',String(show));toggle.setAttribute('aria-label',show?window.uimsT('HidePassword'):window.uimsT('ShowPassword'));
 });
 function resetBusy(){document.querySelectorAll('[data-public-form]').forEach(function(form){
  form.removeAttribute('data-submitting');form.removeAttribute('aria-busy');
  var button=form.querySelector('input[type="submit"]');if(button){button.removeAttribute('aria-disabled');if(button.dataset.originalText)button.value=button.dataset.originalText;}
  var status=form.querySelector('[data-submit-status]');if(status)status.textContent='';
 });}
 document.addEventListener('invalid',resetBusy,true);window.addEventListener('pageshow',resetBusy);
 var alert=document.querySelector('[data-public-form] [role="alert"]');
 if(alert){alert.tabIndex=-1;alert.focus();}
}());

