using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.User_Managment
{
    public class Role
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; } = string.Empty;

        public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    }
}
